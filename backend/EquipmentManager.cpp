#include "EquipmentManager.h"
#include <QDateTime>

EquipmentManager::EquipmentManager(QObject* parent)
    : QObject(parent)
{
    model_.append({ "dev1", "Pump Unit 1",    "10.0.0.11", "qrc:/images/pump.png",            true  });
    model_.append({ "dev2", "Pump Unit 2",    "10.0.0.12", "qrc:/images/pump.png",            false });
    model_.append({ "dev3", "Conveyor Belt",  "10.0.0.21", "qrc:/images/air_circulator.png",  true  });
    model_.append({ "dev4", "Heat Exchanger", "10.0.0.31", "qrc:/images/temp_controller.png", false });
    model_.append({ "dev5", "Air Compressor", "10.0.0.41", "qrc:/images/generator.png",       true  });
    nextId_ = 6;

    connect(&sensorTimer_, &QTimer::timeout, this, &EquipmentManager::updateSensorData);
    sensorTimer_.setInterval(2000);

    setSelectedEquipmentId("dev1");
}

QVariantMap EquipmentManager::selectedEquipment() const
{
    return model_.find(selectedId_).toVariantMap();
}

void EquipmentManager::setSelectedEquipmentId(const QString& id)
{
    if (selectedId_ == id) return;
    selectedId_ = id;

    temperature_ = 0.0;
    power_       = 0.0;
    timeSeries_.clear();
    simulator_.reset();
    emit sensorDataChanged();
    emit selectedTimeSeriesChanged();

    sensorTimer_.start();

    emit selectedEquipmentChanged();
}

void EquipmentManager::updateSensorData()
{
    const auto sample = simulator_.next();
    temperature_ = sample.temperature;
    power_       = sample.power;

    QVariantMap point;
    point["timestampMs"]  = QDateTime::currentMSecsSinceEpoch();
    point["temperature"]  = temperature_;
    point["power"]        = power_;
    timeSeries_.append(point);
    if (timeSeries_.size() > MAX_SERIES)
        timeSeries_.removeFirst();

    emit sensorDataChanged();
    emit selectedTimeSeriesChanged();
}

void EquipmentManager::addEquipment()
{
    const QString id   = "dev" + QString::number(nextId_);
    const QString name = "New Device " + QString::number(nextId_);
    const QString ip   = "10.0.0." + QString::number(nextId_);
    model_.append({ id, name, ip, "qrc:/images/default.png", false });
    nextId_++;
}

void EquipmentManager::removeEquipment(const QString& id)
{
    model_.remove(id);
    if (selectedId_ == id) {
        const QString next = model_.find_first_id();
        selectedId_ = next;
        temperature_ = 0.0;
        power_       = 0.0;
        if (next.isEmpty())
            sensorTimer_.stop();
        emit sensorDataChanged();
        emit selectedEquipmentChanged();
    }
}
