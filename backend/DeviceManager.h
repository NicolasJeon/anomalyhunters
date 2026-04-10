#pragma once

#include <map>
#include <memory>

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

#include "Device.h"
#include "AnomalyDetector.h"
#include "DatabaseManager.h"
#include "DeviceTimeSeriesSimulator.h"

class DeviceMonitor;

// 앱의 핵심 백엔드 — 장비 데이터 소유, CRUD·제어·상태로그 담당
// QML에는 deviceManager (context property) 로 노출된다.
// 실시간 추론/시뮬레이션은 DeviceMonitor에 위임한다.
class DeviceManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList devices
               READ devices NOTIFY devicesChanged)

    Q_PROPERTY(QString selectedDeviceId
               READ selectedDeviceId WRITE setSelectedDeviceId
               NOTIFY selectedDeviceChanged)

    Q_PROPERTY(QVariantMap selectedDevice
               READ selectedDevice NOTIFY selectedDeviceChanged)

    Q_PROPERTY(QVariantList selectedTimeSeries
               READ selectedTimeSeries NOTIFY selectedTimeSeriesChanged)

    Q_PROPERTY(QVariantMap selectedInference
               READ selectedInference NOTIFY selectedInferenceChanged)

    Q_PROPERTY(QVariantList selectedStateLogs
               READ selectedStateLogs NOTIFY selectedStateLogsChanged)

public:
    // 장비 1개의 모든 런타임 데이터
    // DeviceMonitor도 이 struct에 접근한다 (DeviceManager::DeviceEntry).
    struct DeviceEntry {
        Device                           device;
        DeviceTimeSeriesSimulator        simulator;
        std::unique_ptr<AnomalyDetector> detector;
        InferenceState                   inference;
        QVector<TimeSeriesSample>        series;
        QVector<StateLogEntry>           stateLog;
        QString                          prevHealthStatus = "N/A";
    };

    explicit DeviceManager(const QString& modelPath, QObject* parent = nullptr);
    ~DeviceManager();

    // ── Property read ──────────────────────────────────────────────────────
    QVariantList devices()            const;
    QString      selectedDeviceId()   const { return selectedDeviceId_; }
    QVariantMap  selectedDevice()     const;
    QVariantList selectedTimeSeries() const;
    QVariantMap  selectedInference()  const;
    QVariantList selectedStateLogs()  const;

    void setSelectedDeviceId(const QString& id);

    // ── Device CRUD ────────────────────────────────────────────────────────
    Q_INVOKABLE void addDevice(QString name,
                               QString imageSource = QString{});
    Q_INVOKABLE void removeDevice(QString deviceId);
    Q_INVOKABLE void updateDevice(QString deviceId, QString name,
                                  QString imageSource);

    // ── Control ────────────────────────────────────────────────────────────
    Q_INVOKABLE void startDevice(QString deviceId);
    Q_INVOKABLE void stopDevice(QString deviceId);
    Q_INVOKABLE void startAll();
    Q_INVOKABLE void stopAll();

    // ── Simulation speed ───────────────────────────────────────────────────
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();

    // ── Test with Data (DeviceMonitor에 위임) ──────────────────────────────
    Q_INVOKABLE void runTestSeries(QString deviceId, QVariantList series);
    Q_INVOKABLE void clearDeviceDisplay(QString deviceId);

    // ── DB ─────────────────────────────────────────────────────────────────
    Q_INVOKABLE QVariantList queryDeviceStateLogs(const QString& deviceId,
                                                  int limit = 200) const;
    Q_INVOKABLE void manualSaveToDb(QString deviceId, quint64 logId,
                                    float temperature, float power,
                                    QString healthStatus);
    Q_INVOKABLE void clearDeviceStateLogs(QString deviceId);

    // ── DeviceMonitor 접근용 ───────────────────────────────────────────────
    DeviceEntry*       entryFor(const QString& id) const;
    const QStringList& deviceOrder()               const { return deviceOrder_; }
    void appendStateLog(DeviceEntry* e, const QString& event,
                        float temperature, float power);

signals:
    void devicesChanged();
    void selectedDeviceChanged();
    void selectedTimeSeriesChanged();
    void selectedInferenceChanged();
    void selectedStateLogsChanged();

private:
    QString     modelPath_;
    QStringList deviceOrder_;
    std::map<QString, std::unique_ptr<DeviceEntry>> entries_;
    QString     selectedDeviceId_;
    int         nextDeviceNum_ = 1;
    quint64     nextLogId_     = 1;

    std::unique_ptr<DeviceMonitor> monitor_;

    static constexpr int SERIES_WINDOW = 10;
    static constexpr int LOG_BUFFER    = 100;
};
