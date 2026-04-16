#pragma once

#include <map>
#include <memory>

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

#include "Equipment.h"
#include "AnomalyDetector.h"
#include "DatabaseManager.h"
#include "DeviceTimeSeriesSimulator.h"

class EquipmentMonitor;

// Core backend — owns equipment data, handles CRUD/control/state-log
// Exposed to QML as context property "equipmentManager"
// Real-time inference/simulation delegated to EquipmentMonitor
class EquipmentManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList equipment
               READ equipment NOTIFY equipmentChanged)

    Q_PROPERTY(QString selectedEquipmentId
               READ selectedEquipmentId WRITE setSelectedEquipmentId
               NOTIFY selectedEquipmentChanged)

    Q_PROPERTY(QVariantMap selectedEquipment
               READ selectedEquipment NOTIFY selectedEquipmentChanged)

    Q_PROPERTY(QVariantList selectedTimeSeries
               READ selectedTimeSeries NOTIFY selectedTimeSeriesChanged)

    Q_PROPERTY(QVariantMap selectedInference
               READ selectedInference NOTIFY selectedInferenceChanged)

    Q_PROPERTY(QVariantList selectedStateLogs
               READ selectedStateLogs NOTIFY selectedStateLogsChanged)

public:
    // All runtime data for a single equipment unit
    // Also accessed by EquipmentMonitor
    struct EquipmentEntry {
        Equipment                        equipment;
        DeviceTimeSeriesSimulator        simulator;
        std::unique_ptr<AnomalyDetector> detector;
        InferenceState                   inference;
        QVector<TimeSeriesSample>        series;
        QVector<StateLogEntry>           stateLog;
        QString                          prevHealthStatus = "N/A";
    };

    explicit EquipmentManager(QObject* parent = nullptr);
    ~EquipmentManager();

    // Property accessors
    QVariantList equipment()           const;
    QString      selectedEquipmentId() const { return selectedEquipmentId_; }
    QVariantMap  selectedEquipment()   const;
    QVariantList selectedTimeSeries()  const;
    QVariantMap  selectedInference()   const;
    QVariantList selectedStateLogs()   const;

    void setSelectedEquipmentId(const QString& id);

    // Equipment CRUD
    Q_INVOKABLE void addEquipment(QString name,
                                  QString imageSource = QString{},
                                  QString ip = QString{});
    Q_INVOKABLE void removeEquipment(QString equipmentId);
    Q_INVOKABLE void updateEquipment(QString equipmentId, QString name,
                                     QString imageSource, QString ip);

    // Control
    Q_INVOKABLE void startEquipment(QString equipmentId);
    Q_INVOKABLE void stopEquipment(QString equipmentId);
    Q_INVOKABLE void startAll();
    Q_INVOKABLE void stopAll();

    // Simulation speed
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();

    // Test with Data (delegated to EquipmentMonitor)
    Q_INVOKABLE void runTestSeries(QString equipmentId, QVariantList series);
    Q_INVOKABLE void clearEquipmentDisplay(QString equipmentId);

    // DB
    Q_INVOKABLE QVariantList queryEquipmentStateLogs(const QString& equipmentId,
                                                     int limit = 200) const;
    Q_INVOKABLE void manualSaveToDb(QString equipmentId, quint64 logId,
                                    int temperature, int power,
                                    QString healthStatus);
    Q_INVOKABLE void clearEquipmentStateLogs(QString equipmentId);

    // EquipmentMonitor access
    EquipmentEntry*    entryFor(const QString& id) const;
    const QStringList& equipmentOrder()            const { return equipmentOrder_; }
    void appendStateLog(EquipmentEntry* e, const QString& event,
                        int temperature, int power);

signals:
    void equipmentChanged();
    void selectedEquipmentChanged();
    void selectedTimeSeriesChanged();
    void selectedInferenceChanged();
    void selectedStateLogsChanged();

private:
    QStringList equipmentOrder_;
    std::map<QString, std::unique_ptr<EquipmentEntry>> entries_;
    QString     selectedEquipmentId_;
    int         nextEquipmentNum_ = 1;
    quint64     nextLogId_        = 1;

    std::unique_ptr<EquipmentMonitor> monitor_;

    static constexpr int SERIES_WINDOW = 10;
    static constexpr int LOG_BUFFER    = 100;
};
