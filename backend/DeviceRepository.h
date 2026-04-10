#pragma once

#include <map>
#include <memory>

#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include "Device.h"
#include "AnomalyDetector.h"
#include "DatabaseManager.h"
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


    Q_PROPERTY(QVariantList selectedStateLogs
               READ selectedStateLogs NOTIFY selectedStateLogsChanged)

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
    QVariantList selectedStateLogs() const;

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
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();

    // ── Recording ──────────────────────────────────────────────────────────

    // ── Test with Data ─────────────────────────────────────────────────────
    // series: QVariantList of QVariantMap { "temperature": float, "power": float }
    Q_INVOKABLE void runTestSeries(QString deviceId, QVariantList series);

    // Test mode 진입 시 시리즈·추론 상태 초기화 (UI 클린 슬레이트)
    Q_INVOKABLE void clearDeviceDisplay(QString deviceId);

    // ── DB 조회 ────────────────────────────────────────────────────────────
    // DB에 저장된 상태 이벤트를 최신순으로 최대 limit 건 반환
    Q_INVOKABLE QVariantList queryDeviceStateLogs(const QString& deviceId, int limit = 200) const;

    // ── 수동 DB 저장 ───────────────────────────────────────────────────────
    // 온도/전력/상태를 직접 입력하여 DB에 기록 (인메모리 로그에도 추가)
    Q_INVOKABLE void manualSaveToDb(QString deviceId, quint64 logId,
                                    float temperature, float power,
                                    QString healthStatus);

    // ── DB 클리어 ──────────────────────────────────────────────────────────
    // 특정 장비의 DB 이벤트를 모두 삭제
    Q_INVOKABLE void clearDeviceStateLogs(QString deviceId);

signals:
    void devicesChanged();
    void selectedDeviceChanged();
    void selectedTimeSeriesChanged();
    void selectedInferenceChanged();
    void selectedStateLogsChanged();

private slots:
    void tick();

private:
    // ── 장비 1개 분의 모든 런타임 데이터 ─────────────────────────────────
    struct DeviceEntry {
        Device                         device;
        DeviceTimeSeriesSimulator      simulator;
        std::unique_ptr<AnomalyDetector> detector;
        InferenceState                   inference;
        QVector<TimeSeriesSample>        series;
        QVector<StateLogEntry>           stateLog;   // 최근 100건 상태 변화 로그
        QString                          prevHealthStatus = "N/A";
    };

    DeviceEntry* entryFor(const QString& id) const;
    void updateHealthStatus(Device& dev, const InferenceState& inf);
    void appendStateLog(DeviceEntry* e, const QString& event, float temperature, float power);

    QString     modelPath_;
    QStringList deviceOrder_;   // 안정적인 순서 보장
    std::map<QString, std::unique_ptr<DeviceEntry>> entries_;
    QString     selectedDeviceId_;
    QTimer      timer_;
    int         nextDeviceNum_ = 1;
    quint64     nextLogId_     = 1;   // session-scoped log ID counter

    static constexpr int SERIES_BUFFER  = 100;   // 내부 보관 최대 수
    static constexpr int SERIES_WINDOW  =  10;   // QML에 노출되는 수
    static constexpr int LOG_BUFFER     = 100;   // 상태 로그 보관 최대 수
};
