#include "EquipmentMonitor.h"
#include "EquipmentManager.h"

#include <QDateTime>

EquipmentMonitor::EquipmentMonitor(EquipmentManager& manager, QObject* parent)
    : QObject(parent)
    , manager_(manager)
{
    connect(&timer_, &QTimer::timeout, this, &EquipmentMonitor::tick);
    timer_.start(1000);
}

void EquipmentMonitor::startSimulation() { timer_.start(500); }
void EquipmentMonitor::stopSimulation()  { timer_.stop(); }

void EquipmentMonitor::tick()
{
    bool anyRunning         = false;
    bool selectedRunning    = false;
    bool selectedLogChanged = false;
    const QString selectedId = manager_.selectedEquipmentId();

    for (const QString& id : manager_.equipmentOrder()) {
        EquipmentManager::EquipmentEntry* e = manager_.entryFor(id);
        if (!e || e->equipment.controlStatus != "Running") continue;

        anyRunning = true;

        auto s   = e->simulator.next();
        auto res = e->detector->predict(s.temperature, s.power);

        e->inference.label = static_cast<int>(res.finalState);

        const QString prevHealth = e->prevHealthStatus;
        updateHealthStatus(e->equipment, e->inference);
        if (e->equipment.healthStatus != prevHealth) {
            manager_.appendStateLog(e, "health_change", s.temperature, s.power);
            if (id == selectedId) selectedLogChanged = true;
        }
        e->prevHealthStatus = e->equipment.healthStatus;

        TimeSeriesSample ts;
        ts.timestampMs = QDateTime::currentMSecsSinceEpoch();
        ts.temperature = s.temperature;
        ts.power       = s.power;
        ts.label       = e->inference.label;

        if (e->series.size() >= SERIES_BUFFER)
            e->series.removeFirst();
        e->series.append(ts);

        if (id == selectedId) selectedRunning = true;
    }

    if (anyRunning)         emit equipmentUpdated();
    if (selectedRunning)  { emit selectedEquipmentUpdated();
                            emit selectedTimeSeriesUpdated();
                            emit selectedInferenceUpdated(); }
    if (selectedLogChanged) emit selectedStateLogsUpdated();
}

void EquipmentMonitor::updateHealthStatus(Equipment& eq, const InferenceState& inf)
{
    if      (inf.label == -1) eq.healthStatus = "N/A";
    else if (inf.label == 0)  eq.healthStatus = "Normal";
    else if (inf.label == 1)  eq.healthStatus = "Warning";
    else                      eq.healthStatus = "Abnormal";
}

void EquipmentMonitor::runTestSeries(const QString& equipmentId, const QVariantList& series)
{
    EquipmentManager::EquipmentEntry* e = manager_.entryFor(equipmentId);
    if (!e || e->equipment.controlStatus != "Stopped" || series.isEmpty()) return;

    e->inference = InferenceState{};

    AnomalyDetector::Result lastResult;
    for (int i = 0; i < series.size(); ++i) {
        const QVariantMap row = series[i].toMap();
        lastResult = e->detector->predict(
            row.value("temperature").toInt(),
            row.value("power").toInt());
    }

    e->inference.label = static_cast<int>(lastResult.finalState);
    updateHealthStatus(e->equipment, e->inference);

    // time series는 수정하지 않음 — 메인 창 StatusCard가 오염되지 않도록
    emit equipmentUpdated();
    if (equipmentId == manager_.selectedEquipmentId()) {
        emit selectedEquipmentUpdated();
        emit selectedInferenceUpdated();
    }
}

void EquipmentMonitor::clearEquipmentDisplay(const QString& equipmentId)
{
    EquipmentManager::EquipmentEntry* e = manager_.entryFor(equipmentId);
    if (!e) return;

    e->series.clear();
    e->inference = InferenceState{};
    updateHealthStatus(e->equipment, e->inference);

    emit equipmentUpdated();
    if (equipmentId == manager_.selectedEquipmentId()) {
        emit selectedEquipmentUpdated();
        emit selectedTimeSeriesUpdated();
        emit selectedInferenceUpdated();
    }
}
