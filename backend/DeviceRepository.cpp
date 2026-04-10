#include "DeviceRepository.h"

#include <QDateTime>
#include <algorithm>

// ── 소멸자 ────────────────────────────────────────────────────────────────────
DeviceRepository::~DeviceRepository() = default;

// ── 생성자 ────────────────────────────────────────────────────────────────────
DeviceRepository::DeviceRepository(const QString& modelPath, QObject* parent)
    : QObject(parent)
    , modelPath_(modelPath)
{
    connect(&timer_, &QTimer::timeout, this, &DeviceRepository::tick);
    timer_.start(1000);

    // DB에서 장비 목록 로드, 없으면 기본값 삽입
    const QVariantList saved = DatabaseManager::instance().loadDevices();
    if (saved.isEmpty()) {
        addDevice("Air Circulator", "qrc:/qt/qml/QtFacility/images/air_circulator.png");
        addDevice("Temp Controller","qrc:/qt/qml/QtFacility/images/temp_controller.png");
        addDevice("Pump A",         "qrc:/qt/qml/QtFacility/images/pump.png");
        addDevice("Pump B",         "qrc:/qt/qml/QtFacility/images/pump.png");
        addDevice("Generator",      "qrc:/qt/qml/QtFacility/images/generator.png");
    } else {
        for (const QVariant& v : saved) {
            const QVariantMap m = v.toMap();
            const QString id    = m["id"].toString();
            const QString name  = m["name"].toString();
            const QString img   = m["imageSource"].toString();

            // nextDeviceNum_ 복원 — "devN" 형식에서 N 추출
            const QString suffix = id.mid(3);   // "dev" 제거
            bool ok2 = false;
            const int num = suffix.toInt(&ok2);
            if (ok2 && num >= nextDeviceNum_)
                nextDeviceNum_ = num + 1;

            auto entry = std::make_unique<DeviceEntry>();
            entry->device.id            = id;
            entry->device.name          = name;
            entry->device.healthStatus  = "N/A";
            entry->device.controlStatus = "Stopped";
            entry->device.imageSource   = img;

            try {
                entry->detector = std::make_unique<AnomalyDetector>(modelPath_.toStdString());
            } catch (const std::exception& ex) {
                qWarning("AnomalyDetector init failed (%s): %s", qPrintable(id), ex.what());
                continue;
            }

            deviceOrder_.append(id);
            entries_.emplace(id, std::move(entry));
        }
        emit devicesChanged();
    }

    // 첫 번째 장비를 자동 시작 + 선택
    if (!deviceOrder_.isEmpty()) {
        startDevice(deviceOrder_.first());
        setSelectedDeviceId(deviceOrder_.first());
    }
}

// ── tick ──────────────────────────────────────────────────────────────────────
void DeviceRepository::tick()
{
    bool anyRunning = false;
    bool selectedRunning = false;

    for (const QString& id : deviceOrder_) {
        DeviceEntry* e = entryFor(id);
        if (!e || e->device.controlStatus != "Running") continue;

        anyRunning = true;

        // 샘플 생성
        auto s = e->simulator.next();

        // 추론
        auto res = e->detector->predict(s.temperature, s.power);

        e->inference.label        = res.label;
        e->inference.probNormal   = res.prob_normal;
        e->inference.probWarning  = res.prob_warning;
        e->inference.probAbnormal = res.prob_abnormal;

        // healthStatus 갱신 + 상태 변화 감지 → 로그 & DB 기록
        const QString prevHealth = e->prevHealthStatus;
        updateHealthStatus(e->device, e->inference);
        if (e->device.healthStatus != prevHealth) {
            appendStateLog(e, "health_change", s.temperature, s.power);

            if (id == selectedDeviceId_)
                emit selectedStateLogsChanged();
        }
        e->prevHealthStatus = e->device.healthStatus;

        // 시계열 추가
        TimeSeriesSample ts;
        ts.timestampMs  = QDateTime::currentMSecsSinceEpoch();
        ts.temperature  = s.temperature;
        ts.power        = s.power;
        ts.label        = e->inference.label;
        ts.probAbnormal = res.prob_abnormal;

        if (e->series.size() >= SERIES_BUFFER)
            e->series.removeFirst();
        e->series.append(ts);

        if (id == selectedDeviceId_)
            selectedRunning = true;
    }

    if (anyRunning)
        emit devicesChanged();   // healthStatus 변화 반영

    if (selectedRunning) {
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }
}

// ── healthStatus 규칙 ─────────────────────────────────────────────────────────
void DeviceRepository::updateHealthStatus(Device& dev, const InferenceState& inf)
{
    if      (inf.label == -1) dev.healthStatus = "N/A";
    else if (inf.label == 0)  dev.healthStatus = "Normal";
    else if (inf.label == 1)  dev.healthStatus = "Warning";
    else                      dev.healthStatus = "Abnormal";
}

// ── Property accessors ────────────────────────────────────────────────────────
QVariantList DeviceRepository::devices() const
{
    QVariantList list;
    for (const QString& id : deviceOrder_) {
        if (const DeviceEntry* e = entryFor(id))
            list.append(e->device.toVariantMap());
    }
    return list;
}

QVariantMap DeviceRepository::selectedDevice() const
{
    if (const DeviceEntry* e = entryFor(selectedDeviceId_))
        return e->device.toVariantMap();
    return {};
}

QVariantList DeviceRepository::selectedTimeSeries() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    if (!e) return {};

    const auto& s = e->series;
    int start = qMax(0, s.size() - SERIES_WINDOW);

    QVariantList result;
    result.reserve(s.size() - start);
    for (int i = start; i < s.size(); ++i)
        result.append(s[i].toVariantMap());
    return result;
}

QVariantMap DeviceRepository::selectedInference() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    if (!e) return {{"label", -1}, {"probNormal", 0.f},
                    {"probAbnormal", 0.f}, {"statusText", "No Device"}};
    return e->inference.toVariantMap();
}

void DeviceRepository::setSelectedDeviceId(const QString& id)
{
    if (selectedDeviceId_ == id) return;
    selectedDeviceId_ = id;
    emit selectedDeviceChanged();
    emit selectedTimeSeriesChanged();
    emit selectedInferenceChanged();
    emit selectedStateLogsChanged();
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
void DeviceRepository::addDevice(QString name, QString imageSource)
{
    if (name.isEmpty())
        name = "Device " + QString::number(nextDeviceNum_);

    const QString id = "dev" + QString::number(nextDeviceNum_++);

    auto entry = std::make_unique<DeviceEntry>();
    entry->device.id            = id;
    entry->device.name          = name;
    entry->device.healthStatus  = "Stopped";
    entry->device.controlStatus = "Stopped";
    entry->device.imageSource   = imageSource;

    try {
        entry->detector = std::make_unique<AnomalyDetector>(modelPath_.toStdString());
    } catch (const std::exception& ex) {
        qWarning("AnomalyDetector 초기화 실패 (%s): %s", qPrintable(id), ex.what());
        return;
    }

    deviceOrder_.append(id);
    entries_.emplace(id, std::move(entry));

    DatabaseManager::instance().saveNewDevice(id, name, imageSource);

    emit devicesChanged();
}

void DeviceRepository::removeDevice(QString deviceId)
{
    if (!entries_.count(deviceId)) return;

    entries_.erase(deviceId);
    deviceOrder_.removeAll(deviceId);

    DatabaseManager::instance().deleteDevice(deviceId);
    DatabaseManager::instance().clearDeviceEvents(deviceId);

    if (selectedDeviceId_ == deviceId) {
        selectedDeviceId_ = deviceOrder_.isEmpty() ? QString{} : deviceOrder_.first();
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }

    emit devicesChanged();
}

void DeviceRepository::updateDevice(QString deviceId, QString name,
                                    QString imageSource)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    e->device.name        = name;
    e->device.imageSource = imageSource;

    DatabaseManager::instance().updateDevice(deviceId, name, imageSource);

    emit devicesChanged();
    if (deviceId == selectedDeviceId_)
        emit selectedDeviceChanged();
}

// ── Control ───────────────────────────────────────────────────────────────────
void DeviceRepository::startDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus == "Running") return;

    e->device.controlStatus = "Running";

    const float curTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
    const float curPower = e->series.isEmpty() ? 0.f : e->series.last().power;

    appendStateLog(e, "start", curTemp, curPower);

    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedStateLogsChanged();
    }
}

void DeviceRepository::stopDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus == "Stopped") return;

    e->device.controlStatus = "Stopped";

    const float stopTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
    const float stopPower = e->series.isEmpty() ? 0.f : e->series.last().power;

    appendStateLog(e, "stop", stopTemp, stopPower);

    // 정지 후 healthStatus → N/A, 시계열·추론 버퍼 초기화
    e->device.healthStatus = "N/A";
    e->prevHealthStatus    = "N/A";
    e->series.clear();
    e->inference  = InferenceState{};

    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
        emit selectedStateLogsChanged();
    }
}

void DeviceRepository::startAll()
{
    for (const QString& id : deviceOrder_) startDevice(id);
}

void DeviceRepository::stopAll()
{
    for (const QString& id : deviceOrder_) stopDevice(id);
}

void DeviceRepository::startSimulation() { timer_.start(500); }
void DeviceRepository::stopSimulation()  { timer_.stop(); }

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────

// ── clearDeviceDisplay ────────────────────────────────────────────────────────
void DeviceRepository::clearDeviceDisplay(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    e->series.clear();
    e->inference = InferenceState{};
    updateHealthStatus(e->device, e->inference);

    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }
}

// ── Test with Data ────────────────────────────────────────────────────────────
void DeviceRepository::runTestSeries(QString deviceId, QVariantList series)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus != "Stopped" || series.isEmpty()) return;

    // 버퍼 초기화
    e->series.clear();
    e->inference = InferenceState{};

    AnomalyDetector::Result lastResult;
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    const int    n   = series.size();

    for (int i = 0; i < n; ++i) {
        const QVariantMap row  = series[i].toMap();
        const float temp  = row.value("temperature").toFloat();
        const float power = row.value("power").toFloat();

        lastResult = e->detector->predict(temp, power);

        TimeSeriesSample ts;
        ts.timestampMs  = now - static_cast<qint64>(n - 1 - i) * 1000;
        ts.temperature  = temp;
        ts.power        = power;
        ts.label        = lastResult.label;
        ts.probAbnormal = lastResult.prob_abnormal;
        e->series.append(ts);
    }

    e->inference.label        = lastResult.label;
    e->inference.probNormal   = lastResult.prob_normal;
    e->inference.probWarning  = lastResult.prob_warning;
    e->inference.probAbnormal = lastResult.prob_abnormal;

    updateHealthStatus(e->device, e->inference);

    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }
}

// ── manualSaveToDb ────────────────────────────────────────────────────────────
void DeviceRepository::manualSaveToDb(QString deviceId, quint64 logId,
                                      float temperature, float power,
                                      QString healthStatus)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    // logId로 항목을 찾아 savedToDB 플래그 설정 (중복 저장 방지)
    qint64 timestampMs = 0;
    for (auto& le : e->stateLog) {
        if (le.logId == logId) {
            if (le.savedToDB) return;
            le.savedToDB  = true;
            timestampMs   = le.timestampMs;
            break;
        }
    }

    DatabaseManager::instance().insertStateEvent(
        e->device.id, e->device.name,
        healthStatus, e->device.controlStatus,
        temperature, power, timestampMs);

    if (deviceId == selectedDeviceId_)
        emit selectedStateLogsChanged();
}

// ── clearDeviceStateLogs ──────────────────────────────────────────────────────
void DeviceRepository::clearDeviceStateLogs(QString deviceId)
{
    DatabaseManager::instance().clearDeviceEvents(deviceId);
}

// ── selectedStateLogs ─────────────────────────────────────────────────────────
QVariantList DeviceRepository::selectedStateLogs() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    if (!e) return {};

    // 최신순으로 반환 (stateLog는 오래된 순 저장)
    QVariantList result;
    result.reserve(e->stateLog.size());
    for (int i = e->stateLog.size() - 1; i >= 0; --i)
        result.append(e->stateLog[i].toVariantMap());
    return result;
}

// ── queryDeviceStateLogs ──────────────────────────────────────────────────────
QVariantList DeviceRepository::queryDeviceStateLogs(const QString& deviceId, int limit) const
{
    return DatabaseManager::instance().queryStateEvents(deviceId, limit);
}

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
void DeviceRepository::appendStateLog(DeviceEntry* e, const QString& event,
                                      float temperature, float power)
{
    StateLogEntry le;
    le.logId         = nextLogId_++;
    le.timestampMs   = QDateTime::currentMSecsSinceEpoch();
    le.event         = event;
    le.healthStatus  = e->device.healthStatus;
    le.controlStatus = e->device.controlStatus;
    le.temperature   = temperature;
    le.power         = power;

    if (e->stateLog.size() >= LOG_BUFFER)
        e->stateLog.removeFirst();
    e->stateLog.append(le);
}

DeviceRepository::DeviceEntry* DeviceRepository::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it->second.get() : nullptr;
}
