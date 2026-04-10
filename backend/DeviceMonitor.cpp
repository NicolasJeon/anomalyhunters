#include "DeviceMonitor.h"
#include "DeviceManager.h"

#include <QDateTime>

DeviceMonitor::DeviceMonitor(DeviceManager& manager, QObject* parent)
    : QObject(parent)
    , manager_(manager)
{
    connect(&timer_, &QTimer::timeout, this, &DeviceMonitor::tick);
    timer_.start(1000);
}

void DeviceMonitor::startSimulation() { timer_.start(500); }
void DeviceMonitor::stopSimulation()  { timer_.stop(); }

// ── tick ──────────────────────────────────────────────────────────────────────
void DeviceMonitor::tick()
{
    bool anyRunning         = false;
    bool selectedRunning    = false;
    bool selectedLogChanged = false;
    const QString selectedId = manager_.selectedDeviceId();

    for (const QString& id : manager_.deviceOrder()) {
        DeviceManager::DeviceEntry* e = manager_.entryFor(id);
        if (!e || e->device.controlStatus != "Running") continue;

        anyRunning = true;

        auto s   = e->simulator.next();
        auto res = e->detector->predict(s.temperature, s.power);

        e->inference.label        = res.label;
        e->inference.probNormal   = res.prob_normal;
        e->inference.probWarning  = res.prob_warning;
        e->inference.probAbnormal = res.prob_abnormal;

        const QString prevHealth = e->prevHealthStatus;
        updateHealthStatus(e->device, e->inference);
        if (e->device.healthStatus != prevHealth) {
            manager_.appendStateLog(e, "health_change", s.temperature, s.power);
            if (id == selectedId) selectedLogChanged = true;
        }
        e->prevHealthStatus = e->device.healthStatus;

        TimeSeriesSample ts;
        ts.timestampMs  = QDateTime::currentMSecsSinceEpoch();
        ts.temperature  = s.temperature;
        ts.power        = s.power;
        ts.label        = e->inference.label;
        ts.probAbnormal = res.prob_abnormal;

        if (e->series.size() >= SERIES_BUFFER)
            e->series.removeFirst();
        e->series.append(ts);

        if (id == selectedId) selectedRunning = true;
    }

    if (anyRunning)         emit devicesUpdated();
    if (selectedRunning)  { emit selectedDeviceUpdated();
                            emit selectedTimeSeriesUpdated();
                            emit selectedInferenceUpdated(); }
    if (selectedLogChanged) emit selectedStateLogsUpdated();
}

// ── healthStatus 갱신 ─────────────────────────────────────────────────────────
void DeviceMonitor::updateHealthStatus(Device& dev, const InferenceState& inf)
{
    if      (inf.label == -1) dev.healthStatus = "N/A";
    else if (inf.label == 0)  dev.healthStatus = "Normal";
    else if (inf.label == 1)  dev.healthStatus = "Warning";
    else                      dev.healthStatus = "Abnormal";
}

// ── runTestSeries ─────────────────────────────────────────────────────────────
void DeviceMonitor::runTestSeries(const QString& deviceId, const QVariantList& series)
{
    DeviceManager::DeviceEntry* e = manager_.entryFor(deviceId);
    if (!e || e->device.controlStatus != "Stopped" || series.isEmpty()) return;

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

    emit devicesUpdated();
    if (deviceId == manager_.selectedDeviceId()) {
        emit selectedDeviceUpdated();
        emit selectedTimeSeriesUpdated();
        emit selectedInferenceUpdated();
    }
}

// ── clearDeviceDisplay ────────────────────────────────────────────────────────
void DeviceMonitor::clearDeviceDisplay(const QString& deviceId)
{
    DeviceManager::DeviceEntry* e = manager_.entryFor(deviceId);
    if (!e) return;

    e->series.clear();
    e->inference = InferenceState{};
    updateHealthStatus(e->device, e->inference);

    emit devicesUpdated();
    if (deviceId == manager_.selectedDeviceId()) {
        emit selectedDeviceUpdated();
        emit selectedTimeSeriesUpdated();
        emit selectedInferenceUpdated();
    }
}
