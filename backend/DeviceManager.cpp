#include "DeviceManager.h"
#include "DeviceMonitor.h"

#include <QDateTime>

// ── 소멸자 ────────────────────────────────────────────────────────────────────
DeviceManager::~DeviceManager() = default;

// ── 생성자 ────────────────────────────────────────────────────────────────────
DeviceManager::DeviceManager(const QString& modelPath, QObject* parent)
    : QObject(parent)
    , modelPath_(modelPath)
{
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
            const QString suffix = id.mid(3);
            bool ok = false;
            const int num = suffix.toInt(&ok);
            if (ok && num >= nextDeviceNum_)
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

    // DeviceMonitor 생성 및 signal 연결
    monitor_ = std::make_unique<DeviceMonitor>(*this);
    connect(monitor_.get(), &DeviceMonitor::devicesUpdated,
            this, &DeviceManager::devicesChanged);
    connect(monitor_.get(), &DeviceMonitor::selectedDeviceUpdated,
            this, &DeviceManager::selectedDeviceChanged);
    connect(monitor_.get(), &DeviceMonitor::selectedTimeSeriesUpdated,
            this, &DeviceManager::selectedTimeSeriesChanged);
    connect(monitor_.get(), &DeviceMonitor::selectedInferenceUpdated,
            this, &DeviceManager::selectedInferenceChanged);
    connect(monitor_.get(), &DeviceMonitor::selectedStateLogsUpdated,
            this, &DeviceManager::selectedStateLogsChanged);

    // 첫 번째 장비 자동 시작 + 선택
    if (!deviceOrder_.isEmpty()) {
        startDevice(deviceOrder_.first());
        setSelectedDeviceId(deviceOrder_.first());
    }
}

// ── Property accessors ────────────────────────────────────────────────────────
QVariantList DeviceManager::devices() const
{
    QVariantList list;
    for (const QString& id : deviceOrder_) {
        if (const DeviceEntry* e = entryFor(id))
            list.append(e->device.toVariantMap());
    }
    return list;
}

QVariantMap DeviceManager::selectedDevice() const
{
    if (const DeviceEntry* e = entryFor(selectedDeviceId_))
        return e->device.toVariantMap();
    return {};
}

QVariantList DeviceManager::selectedTimeSeries() const
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

QVariantMap DeviceManager::selectedInference() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    if (!e) return {{"label", -1}, {"probNormal", 0.f},
                    {"probAbnormal", 0.f}, {"statusText", "No Device"}};
    return e->inference.toVariantMap();
}

QVariantList DeviceManager::selectedStateLogs() const
{
    const DeviceEntry* e = entryFor(selectedDeviceId_);
    if (!e) return {};

    QVariantList result;
    result.reserve(e->stateLog.size());
    for (int i = e->stateLog.size() - 1; i >= 0; --i)
        result.append(e->stateLog[i].toVariantMap());
    return result;
}

void DeviceManager::setSelectedDeviceId(const QString& id)
{
    if (selectedDeviceId_ == id) return;
    selectedDeviceId_ = id;
    emit selectedDeviceChanged();
    emit selectedTimeSeriesChanged();
    emit selectedInferenceChanged();
    emit selectedStateLogsChanged();
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
void DeviceManager::addDevice(QString name, QString imageSource)
{
    if (name.isEmpty())
        name = "Device " + QString::number(nextDeviceNum_);

    const QString id = "dev" + QString::number(nextDeviceNum_++);

    auto entry = std::make_unique<DeviceEntry>();
    entry->device.id            = id;
    entry->device.name          = name;
    entry->device.healthStatus  = "N/A";
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

void DeviceManager::removeDevice(QString deviceId)
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

void DeviceManager::updateDevice(QString deviceId, QString name, QString imageSource)
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
void DeviceManager::startDevice(QString deviceId)
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

void DeviceManager::stopDevice(QString deviceId)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e || e->device.controlStatus == "Stopped") return;

    e->device.controlStatus = "Stopped";

    const float stopTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
    const float stopPower = e->series.isEmpty() ? 0.f : e->series.last().power;

    appendStateLog(e, "stop", stopTemp, stopPower);

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

void DeviceManager::startAll()
{
    for (const QString& id : deviceOrder_) startDevice(id);
}

void DeviceManager::stopAll()
{
    for (const QString& id : deviceOrder_) stopDevice(id);
}

// ── Simulation speed (DeviceMonitor에 위임) ───────────────────────────────────
void DeviceManager::startSimulation() { monitor_->startSimulation(); }
void DeviceManager::stopSimulation()  { monitor_->stopSimulation(); }

// ── Test with Data (DeviceMonitor에 위임) ─────────────────────────────────────
void DeviceManager::runTestSeries(QString deviceId, QVariantList series)
{
    monitor_->runTestSeries(deviceId, series);
}

void DeviceManager::clearDeviceDisplay(QString deviceId)
{
    monitor_->clearDeviceDisplay(deviceId);
}

// ── DB ────────────────────────────────────────────────────────────────────────
QVariantList DeviceManager::queryDeviceStateLogs(const QString& deviceId, int limit) const
{
    return DatabaseManager::instance().queryStateEvents(deviceId, limit);
}

void DeviceManager::manualSaveToDb(QString deviceId, quint64 logId,
                                   float temperature, float power,
                                   QString healthStatus)
{
    DeviceEntry* e = entryFor(deviceId);
    if (!e) return;

    qint64 timestampMs = 0;
    for (auto& le : e->stateLog) {
        if (le.logId == logId) {
            if (le.savedToDB) return;
            le.savedToDB = true;
            timestampMs  = le.timestampMs;
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

void DeviceManager::clearDeviceStateLogs(QString deviceId)
{
    DatabaseManager::instance().clearDeviceEvents(deviceId);
}

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
void DeviceManager::appendStateLog(DeviceEntry* e, const QString& event,
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

DeviceManager::DeviceEntry* DeviceManager::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it->second.get() : nullptr;
}
