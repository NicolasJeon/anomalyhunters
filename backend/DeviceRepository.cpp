#include "DeviceRepository.h"

#include <QDateTime>

// ── 소멸자 ────────────────────────────────────────────────────────────────────
DeviceRepository::~DeviceRepository()
{
    qDeleteAll(entries_);
}

// ── 생성자 ────────────────────────────────────────────────────────────────────
DeviceRepository::DeviceRepository(const QString& modelPath, QObject* parent)
    : QObject(parent)
    , modelPath_(modelPath)
{
    connect(&timer_, &QTimer::timeout, this, &DeviceRepository::tick);
    timer_.start(1000);

    // 초기 장비 5개
    addDevice("공기순환기", "Air Circulator",         "qrc:/qt/qml/QtFacility/images/air_circulator.png");
    addDevice("온도조절기", "Temperature Controller", "qrc:/qt/qml/QtFacility/images/temp_controller.png");
    addDevice("펌프 A",     "Pump",                   "qrc:/qt/qml/QtFacility/images/pump.png");
    addDevice("펌프 B",     "Pump",                   "qrc:/qt/qml/QtFacility/images/pump.png");
    addDevice("발전기",     "Generator",              "qrc:/qt/qml/QtFacility/images/generator.png");

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
        if (!e || e->device.controlStatus != "running") continue;

        anyRunning = true;

        // 샘플 생성
        auto s = e->simulator.next();

        // 추론
        auto res = e->detector->push(s.temperature, s.power);

        e->inference.label        = res.label;
        e->inference.probNormal   = res.prob_normal;
        e->inference.probWarning  = res.prob_warning;
        e->inference.probAbnormal = res.prob_abnormal;

        // healthStatus 갱신 + 상태 변화 감지 → DB 기록
        const QString prevHealth = e->prevHealthStatus;
        updateHealthStatus(e->device, e->inference);
        if (e->recording && e->device.healthStatus != prevHealth) {
            const float lastTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
            const float lastPower = e->series.isEmpty() ? 0.f : e->series.last().power;
            DatabaseManager::instance().insertStateEvent(
                e->device.id, e->device.name,
                e->device.healthStatus, e->device.controlStatus,
                lastTemp, lastPower,
                e->inference.label,
                e->inference.probNormal, e->inference.probWarning, e->inference.probAbnormal);
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
    if (inf.label <= 0)      dev.healthStatus = "normal";
    else if (inf.label == 1) dev.healthStatus = "warning";
    else                     dev.healthStatus = "anomaly";
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
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
void DeviceRepository::addDevice(QString name, QString type, QString imageSource)
{
    if (name.isEmpty())
        name = "Device " + QString::number(nextDeviceNum_);

    const QString id = "dev" + QString::number(nextDeviceNum_++);

    DeviceEntry* entry = new DeviceEntry();
    entry->device.id            = id;
    entry->device.name          = name;
    entry->device.type          = type;
    entry->device.healthStatus  = "normal";
    entry->device.controlStatus = "stopped";
    entry->device.imageSource   = imageSource;

    try {
        entry->detector = new AnomalyDetector(modelPath_.toStdString());
    } catch (const std::exception& ex) {
        qWarning("AnomalyDetector 초기화 실패 (%s): %s", qPrintable(id), ex.what());
        delete entry;
        return;
    }

    deviceOrder_.append(id);
    entries_.insert(id, entry);

    emit devicesChanged();
}

void DeviceRepository::removeDevice(QString deviceId)
{
    if (!entries_.contains(deviceId)) return;

    delete entries_.take(deviceId);
    deviceOrder_.removeAll(deviceId);

    if (selectedDeviceId_ == deviceId) {
        selectedDeviceId_ = deviceOrder_.isEmpty() ? QString{} : deviceOrder_.first();
        emit selectedDeviceChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }

    emit devicesChanged();
}

void DeviceRepository::updateDevice(QString deviceId, QString name,
                                    QString type, QString imageSource)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    e->device.name        = name;
    e->device.type        = type;
    e->device.imageSource = imageSource;

    emit devicesChanged();
    if (deviceId == selectedDeviceId_)
        emit selectedDeviceChanged();
}

// ── Control ───────────────────────────────────────────────────────────────────
void DeviceRepository::startDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    // emergency 상태에서는 직접 시작 불가 — resetDevice 후 start 해야 함
    if (!e || e->device.controlStatus == "running"
           || e->device.controlStatus == "emergency") return;

    e->device.controlStatus = "running";
    emit devicesChanged();
    if (deviceId == selectedDeviceId_)
        emit selectedDeviceChanged();
}

void DeviceRepository::stopDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus == "stopped") return;

    e->device.controlStatus = "stopped";
    emit devicesChanged();
    if (deviceId == selectedDeviceId_)
        emit selectedDeviceChanged();
}

void DeviceRepository::emergencyStop(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus != "running") return;

    e->device.controlStatus = "emergency";
    e->device.healthStatus  = "emergency";
    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedInferenceChanged();
    }
}

void DeviceRepository::resetDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus != "emergency") return;

    e->device.controlStatus = "stopped";
    e->device.healthStatus  = "normal";
    e->inference            = InferenceState{};   // 추론 상태 초기화
    emit devicesChanged();
    if (deviceId == selectedDeviceId_) {
        emit selectedDeviceChanged();
        emit selectedInferenceChanged();
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

void DeviceRepository::emergencyStopAll()
{
    for (const QString& id : deviceOrder_) emergencyStop(id);
}

void DeviceRepository::startSimulation() { timer_.start(500); }
void DeviceRepository::stopSimulation()  { timer_.stop(); }

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
// ── Recording ─────────────────────────────────────────────────────────────────
bool DeviceRepository::selectedDeviceRecording() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    return e ? e->recording : false;
}

void DeviceRepository::toggleRecording(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    e->recording = !e->recording;

    if (deviceId == selectedDeviceId_)
        emit selectedDeviceChanged();
}

// ── clearDeviceDisplay ────────────────────────────────────────────────────────
void DeviceRepository::clearDeviceDisplay(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    e->detector->reset();
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
    if (!e || e->device.controlStatus != "stopped" || series.isEmpty()) return;

    // 버퍼 초기화
    e->detector->reset();
    e->series.clear();
    e->inference = InferenceState{};

    AnomalyDetector::Result lastResult;
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    const int    n   = series.size();

    for (int i = 0; i < n; ++i) {
        const QVariantMap row  = series[i].toMap();
        const float temp  = row.value("temperature").toFloat();
        const float power = row.value("power").toFloat();

        lastResult = e->detector->push(temp, power);

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

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
DeviceRepository::DeviceEntry* DeviceRepository::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it.value() : nullptr;
}
