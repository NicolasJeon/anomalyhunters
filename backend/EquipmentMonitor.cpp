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

// ── tick ──────────────────────────────────────────────────────────────────────
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

        e->inference.label        = res.label;
        e->inference.probNormal   = res.prob_normal;
        e->inference.probWarning  = res.prob_warning;
        e->inference.probAbnormal = res.prob_abnormal;

        const QString prevHealth = e->prevHealthStatus;
        updateHealthStatus(e->equipment, e->inference);
        if (e->equipment.healthStatus != prevHealth) {
            manager_.appendStateLog(e, "health_change", s.temperature, s.power);
            if (id == selectedId) selectedLogChanged = true;
        }
        e->prevHealthStatus = e->equipment.healthStatus;

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

    if (anyRunning)         emit equipmentUpdated();
    if (selectedRunning)  { emit selectedEquipmentUpdated();
                            emit selectedTimeSeriesUpdated();
                            emit selectedInferenceUpdated(); }
    if (selectedLogChanged) emit selectedStateLogsUpdated();
}

// ── healthStatus 갱신 ─────────────────────────────────────────────────────────
void EquipmentMonitor::updateHealthStatus(Equipment& eq, const InferenceState& inf)
{
    if      (inf.label == -1) eq.healthStatus = "N/A";
    else if (inf.label == 0)  eq.healthStatus = "Normal";
    else if (inf.label == 1)  eq.healthStatus = "Warning";
    else                      eq.healthStatus = "Abnormal";
}

// ── runTestSeries ─────────────────────────────────────────────────────────────
void EquipmentMonitor::runTestSeries(const QString& equipmentId, const QVariantList& series)
{
    EquipmentManager::EquipmentEntry* e = manager_.entryFor(equipmentId);
    if (!e || e->equipment.controlStatus != "Stopped" || series.isEmpty()) return;

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

    updateHealthStatus(e->equipment, e->inference);

    emit equipmentUpdated();
    if (equipmentId == manager_.selectedEquipmentId()) {
        emit selectedEquipmentUpdated();
        emit selectedTimeSeriesUpdated();
        emit selectedInferenceUpdated();
    }
}

// ── clearEquipmentDisplay ─────────────────────────────────────────────────────
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
