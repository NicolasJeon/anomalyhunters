#pragma once
#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>
#include "DeviceTimeSeriesSimulator.h"
#include "EquipmentListModel.h"

class EquipmentManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(EquipmentListModel* equipmentListModel
               READ equipmentListModel CONSTANT)

    Q_PROPERTY(QString selectedEquipmentId
               READ selectedEquipmentId WRITE setSelectedEquipmentId
               NOTIFY selectedEquipmentChanged)

    Q_PROPERTY(QVariantMap selectedEquipment
               READ selectedEquipment NOTIFY selectedEquipmentChanged)

    Q_PROPERTY(qreal selectedTemperature
               READ selectedTemperature NOTIFY sensorDataChanged)

    Q_PROPERTY(qreal selectedPower
               READ selectedPower NOTIFY sensorDataChanged)

    Q_PROPERTY(QVariantList selectedTimeSeries
               READ selectedTimeSeries NOTIFY selectedTimeSeriesChanged)

public:
    explicit EquipmentManager(QObject* parent = nullptr);

    EquipmentListModel* equipmentListModel() { return &model_; }

    QString     selectedEquipmentId()  const { return selectedId_; }
    QVariantMap selectedEquipment()    const;
    qreal       selectedTemperature()  const { return temperature_; }
    qreal       selectedPower()        const { return power_; }
    QVariantList selectedTimeSeries()  const { return timeSeries_; }

    void setSelectedEquipmentId(const QString& id);

    Q_INVOKABLE void addEquipment();
    Q_INVOKABLE void removeEquipment(const QString& id);

signals:
    void selectedEquipmentChanged();
    void sensorDataChanged();
    void selectedTimeSeriesChanged();

private:
    void updateSensorData();

    static constexpr int MAX_SERIES = 30;

    EquipmentListModel       model_;
    DeviceTimeSeriesSimulator simulator_;
    QString                  selectedId_;
    int                      nextId_ = 1;
    qreal                    temperature_ = 0.0;
    qreal                    power_       = 0.0;
    QVariantList             timeSeries_;
    QTimer                   sensorTimer_;
};
