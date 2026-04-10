#pragma once

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantList>

#include "Device.h"

class DeviceManager;

// 실시간 처리 — 1초 tick, 시뮬레이션, ONNX 추론, healthStatus 갱신
// DeviceManager가 소유하며 QML에 직접 노출되지 않는다.
class DeviceMonitor : public QObject
{
    Q_OBJECT
public:
    explicit DeviceMonitor(DeviceManager& manager, QObject* parent = nullptr);

    void startSimulation();
    void stopSimulation();
    void runTestSeries(const QString& deviceId, const QVariantList& series);
    void clearDeviceDisplay(const QString& deviceId);

signals:
    void devicesUpdated();
    void selectedDeviceUpdated();
    void selectedTimeSeriesUpdated();
    void selectedInferenceUpdated();
    void selectedStateLogsUpdated();

private slots:
    void tick();

private:
    static void updateHealthStatus(Device& dev, const InferenceState& inf);

    DeviceManager& manager_;
    QTimer         timer_;

    static constexpr int SERIES_BUFFER = 100;
};
