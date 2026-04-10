#pragma once

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantList>

#include "Equipment.h"

class EquipmentManager;

// 실시간 처리 — 1초 tick, 시뮬레이션, ONNX 추론, healthStatus 갱신
// EquipmentManager가 소유하며 QML에 직접 노출되지 않는다.
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
