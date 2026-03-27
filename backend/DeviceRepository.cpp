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
    timer_.start(500);

    // 초기 샘플 장비 3개
    addDevice("Compressor A", "Compressor");
    addDevice("Pump B",       "Pump");
    addDevice("Motor C",      "Motor");

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
        e->inference.probAbnormal = res.prob_abnormal;

        // healthStatus 갱신
        updateHealthStatus(e->device, e->inference);

        // 시계열 추가
        TimeSeriesSample ts;
        ts.timestampMs  = QDateTime::currentMSecsSinceEpoch();
        ts.temperature  = s.temperature;
        ts.power        = s.power;
        ts.label        = res.label;
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
    if (inf.label == -1 || inf.probAbnormal < 0.4f)
        dev.healthStatus = "normal";
    else if (inf.probAbnormal < 0.7f)
        dev.healthStatus = "warning";
    else
        dev.healthStatus = "anomaly";
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

void DeviceRepository::startSimulation() { timer_.start(500); }
void DeviceRepository::stopSimulation()  { timer_.stop(); }

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
DeviceRepository::DeviceEntry* DeviceRepository::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it.value() : nullptr;
}
