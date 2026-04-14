#pragma once

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantList>

#include "Equipment.h"

class EquipmentManager;

// Real-time processor: 1s tick, simulation, inference, healthStatus update
// Owned by EquipmentManager; not exposed to QML.
class EquipmentMonitor : public QObject
{
    Q_OBJECT
public:
    explicit EquipmentMonitor(EquipmentManager& manager, QObject* parent = nullptr);

    void startSimulation();
    void stopSimulation();
    void runTestSeries(const QString& equipmentId, const QVariantList& series);
    void clearEquipmentDisplay(const QString& equipmentId);

signals:
    void equipmentUpdated();
    void selectedEquipmentUpdated();
    void selectedTimeSeriesUpdated();
    void selectedInferenceUpdated();
    void selectedStateLogsUpdated();

private slots:
    void tick();

private:
    static void updateHealthStatus(Equipment& eq, const InferenceState& inf);

    EquipmentManager& manager_;
    QTimer            timer_;

    static constexpr int SERIES_BUFFER = 100;
};
