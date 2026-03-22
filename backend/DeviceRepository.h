#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <QHash>
#include <QStringList>
#include "Device.h"
#include "AnomalyDetector.h"
#include "DeviceTimeSeriesSimulator.h"

// 앱의 핵심 백엔드 — 모든 장비 데이터와 추론 상태를 관리한다.
// QML에는 repository (context property) 로 노출된다.
class DeviceRepository : public QObject
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

public:
    explicit DeviceRepository(const QString& modelPath,
                              QObject* parent = nullptr);
    ~DeviceRepository();

    // ── Property read ──────────────────────────────────────────────────────
    QVariantList devices()           const;
    QString      selectedDeviceId()  const { return selectedDeviceId_; }
    QVariantMap  selectedDevice()    const;
    QVariantList selectedTimeSeries() const;
    QVariantMap  selectedInference() const;

    void setSelectedDeviceId(const QString& id);

    // ── Device CRUD ────────────────────────────────────────────────────────
    Q_INVOKABLE void addDevice(QString name, QString type,
                               QString imageSource = QString{});
    Q_INVOKABLE void removeDevice(QString deviceId);
    Q_INVOKABLE void updateDevice(QString deviceId, QString name,
                                  QString type, QString imageSource);

    // ── Control ────────────────────────────────────────────────────────────
    Q_INVOKABLE void startDevice(QString deviceId);
    Q_INVOKABLE void stopDevice(QString deviceId);
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();

signals:
    void devicesChanged();
    void selectedDeviceChanged();
    void selectedTimeSeriesChanged();
    void selectedInferenceChanged();

private slots:
    void tick();

private:
    // ── 장비 1개 분의 모든 런타임 데이터 ─────────────────────────────────
    struct DeviceEntry {
        Device                    device;
        DeviceTimeSeriesSimulator simulator;
        AnomalyDetector*          detector = nullptr;
        InferenceState            inference;
        QVector<TimeSeriesSample> series;

        ~DeviceEntry() { delete detector; }
    };

    DeviceEntry* entryFor(const QString& id) const;
    void updateHealthStatus(Device& dev, const InferenceState& inf);

    QString     modelPath_;
    QStringList deviceOrder_;   // 안정적인 순서 보장
    QHash<QString, DeviceEntry*> entries_;  // raw ptr — qDeleteAll on destroy
    QString     selectedDeviceId_;
    QTimer      timer_;
    int         nextDeviceNum_ = 1;

    static constexpr int SERIES_BUFFER  = 100;   // 내부 보관 최대 수
    static constexpr int SERIES_WINDOW  =  20;   // QML에 노출되는 수
};
