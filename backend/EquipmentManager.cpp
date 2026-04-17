#include "EquipmentManager.h"
#include "EquipmentMonitor.h"

#include <QDateTime>

EquipmentManager::~EquipmentManager() = default;

EquipmentManager::EquipmentManager(QObject* parent)
    : QObject(parent)
{
    // Load from DB; seed defaults if empty
    const QVariantList saved = DatabaseManager::instance().loadEquipment();
    if (saved.isEmpty()) {
        addEquipment("Air Circulator", "qrc:/images/air_circulator.png", "192.168.0.101");
        addEquipment("Temp Controller","qrc:/images/temp_controller.png","192.168.0.102");
        addEquipment("Pump A",         "qrc:/images/pump.png",           "192.168.0.103");
        addEquipment("Pump B",         "qrc:/images/pump.png",           "192.168.0.104");
        addEquipment("Generator",      "qrc:/images/generator.png",      "192.168.0.105");
    } else {
        for (const QVariant& v : saved) {
            const QVariantMap m = v.toMap();
            const QString id    = m["id"].toString();
            const QString name  = m["name"].toString();
            const QString img   = m["imageSource"].toString();
            const QString ip    = m["ip"].toString();

            // Restore nextEquipmentNum_ from "devN" id format
            const QString suffix = id.mid(3);
            bool ok = false;
            const int num = suffix.toInt(&ok);
            if (ok && num >= nextEquipmentNum_)
                nextEquipmentNum_ = num + 1;

            auto entry = std::make_unique<EquipmentEntry>();
            entry->equipment.id            = id;
            entry->equipment.name          = name;
            entry->equipment.healthStatus  = "N/A";
            entry->equipment.controlStatus = "Stopped";
            entry->equipment.imageSource   = img;
            entry->equipment.ip            = ip;
            entry->simulator               = DeviceTimeSeriesSimulator(equipmentOrder_.size());
            entry->detector                = std::make_unique<AnomalyDetector>();

            equipmentOrder_.append(id);
            equipmentListModel_.append(entry->equipment);
            entries_.emplace(id, std::move(entry));
        }
        emit equipmentChanged();
    }

    // Create monitor and wire signals
    monitor_ = std::make_unique<EquipmentMonitor>(*this);
    connect(monitor_.get(), &EquipmentMonitor::equipmentUpdated,
            this, &EquipmentManager::equipmentChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedEquipmentUpdated,
            this, &EquipmentManager::selectedEquipmentChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedTimeSeriesUpdated,
            this, &EquipmentManager::selectedTimeSeriesChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedInferenceUpdated,
            this, &EquipmentManager::selectedInferenceChanged);

    // Select first equipment (do not auto-start)
    if (!equipmentOrder_.isEmpty())
        setSelectedEquipmentId(equipmentOrder_.first());
}

QVariantMap EquipmentManager::selectedEquipment() const
{
    if (const EquipmentEntry* e = entryFor(selectedEquipmentId_))
        return e->equipment.toVariantMap();
    return {};
}

QVariantList EquipmentManager::selectedTimeSeries() const
{
    const EquipmentEntry* e = entryFor(selectedEquipmentId_);
    if (!e) return {};

    const auto& s = e->series;
    int start = qMax(0, s.size() - SERIES_WINDOW);

    QVariantList result;
    result.reserve(s.size() - start);
    for (int i = start; i < s.size(); ++i)
        result.append(s[i].toVariantMap());
    return result;
}

QVariantMap EquipmentManager::selectedInference() const
{
    const EquipmentEntry* e = entryFor(selectedEquipmentId_);
    if (!e) return {{"label", -1}, {"statusText", "No Equipment"}};
    return e->inference.toVariantMap();
}

void EquipmentManager::setSelectedEquipmentId(const QString& id)
{
    if (selectedEquipmentId_ == id) return;
    selectedEquipmentId_ = id;

    const EquipmentEntry* e = entryFor(id);
    stateLogModel_.setAll(e ? e->stateLog : QVector<StateLogEntry>{});

    emit selectedEquipmentChanged();
    emit selectedTimeSeriesChanged();
    emit selectedInferenceChanged();
}

void EquipmentManager::addEquipment(QString name, QString imageSource, QString ip)
{
    if (name.isEmpty())
        name = "Equipment " + QString::number(nextEquipmentNum_);

    const QString id = "dev" + QString::number(nextEquipmentNum_++);

    auto entry = std::make_unique<EquipmentEntry>();
    entry->equipment.id            = id;
    entry->equipment.name          = name;
    entry->equipment.healthStatus  = "N/A";
    entry->equipment.controlStatus = "Stopped";
    entry->equipment.imageSource   = imageSource;
    entry->equipment.ip            = ip;
    entry->simulator               = DeviceTimeSeriesSimulator(equipmentOrder_.size());
    entry->detector                = std::make_unique<AnomalyDetector>();

    equipmentOrder_.append(id);
    equipmentListModel_.append(entry->equipment);
    entries_.emplace(id, std::move(entry));

    DatabaseManager::instance().saveNewEquipment(id, name, imageSource, ip);
    emit equipmentChanged();
}

void EquipmentManager::removeEquipment(QString equipmentId)
{
    if (!entries_.count(equipmentId)) return;

    entries_.erase(equipmentId);
    equipmentOrder_.removeAll(equipmentId);
    equipmentListModel_.remove(equipmentId);

    DatabaseManager::instance().deleteEquipment(equipmentId);
    DatabaseManager::instance().clearEquipmentEvents(equipmentId);

    if (selectedEquipmentId_ == equipmentId) {
        selectedEquipmentId_ = equipmentOrder_.isEmpty() ? QString{} : equipmentOrder_.first();
        const EquipmentEntry* newE = entryFor(selectedEquipmentId_);
        stateLogModel_.setAll(newE ? newE->stateLog : QVector<StateLogEntry>{});
        emit selectedEquipmentChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }

    emit equipmentChanged();
}

void EquipmentManager::updateEquipment(QString equipmentId, QString name,
                                       QString imageSource, QString ip)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e) return;

    e->equipment.name        = name;
    e->equipment.imageSource = imageSource;
    e->equipment.ip          = ip;

    DatabaseManager::instance().updateEquipment(equipmentId, name, imageSource, ip);
    equipmentListModel_.update(equipmentId, name, imageSource, ip);

    if (equipmentId == selectedEquipmentId_)
        emit selectedEquipmentChanged();
}

void EquipmentManager::startEquipment(QString equipmentId)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e || e->equipment.controlStatus == "Running") return;

    e->equipment.controlStatus = "Running";

    const int curTemp  = e->series.isEmpty() ? 0 : e->series.last().temperature;
    const int curPower = e->series.isEmpty() ? 0 : e->series.last().power;

    appendStateLog(e, "start", curTemp, curPower);
    equipmentListModel_.updateStatus(equipmentId, e->equipment.healthStatus, "Running");
    emit equipmentChanged();

    if (equipmentId == selectedEquipmentId_)
        emit selectedEquipmentChanged();
}

void EquipmentManager::stopEquipment(QString equipmentId)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e || e->equipment.controlStatus == "Stopped") return;

    e->equipment.controlStatus = "Stopped";

    const int stopTemp  = e->series.isEmpty() ? 0 : e->series.last().temperature;
    const int stopPower = e->series.isEmpty() ? 0 : e->series.last().power;

    appendStateLog(e, "stop", stopTemp, stopPower);

    e->equipment.healthStatus = "N/A";
    e->prevHealthStatus       = "N/A";
    e->series.clear();
    e->inference = InferenceState{};

    equipmentListModel_.updateStatus(equipmentId, "N/A", "Stopped");
    emit equipmentChanged();

    if (equipmentId == selectedEquipmentId_) {
        emit selectedEquipmentChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }
}

void EquipmentManager::startAll() { for (const QString& id : equipmentOrder_) startEquipment(id); }
void EquipmentManager::stopAll()  { for (const QString& id : equipmentOrder_) stopEquipment(id); }

void EquipmentManager::startSimulation() { monitor_->startSimulation(); }
void EquipmentManager::stopSimulation()  { monitor_->stopSimulation(); }

void EquipmentManager::runTestSeries(QString equipmentId, QVariantList series)
{
    monitor_->runTestSeries(equipmentId, series);
}

void EquipmentManager::clearEquipmentDisplay(QString equipmentId)
{
    monitor_->clearEquipmentDisplay(equipmentId);
}

QVariantList EquipmentManager::queryEquipmentStateLogs(const QString& equipmentId, int limit) const
{
    return DatabaseManager::instance().queryStateEvents(equipmentId, limit);
}

void EquipmentManager::manualSaveToDb(QString equipmentId, quint64 logId,
                                      int temperature, int power,
                                      QString healthStatus)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e) return;

    qint64 timestampMs = 0;
    for (auto& le : e->stateLog) {
        if (le.logId == logId) {
            if (le.savedToDB) return;
            le.savedToDB = true;
            timestampMs  = le.timestampMs;
            break;
        }
    }

    DatabaseManager::instance().insertStateEvent(
        e->equipment.id, e->equipment.name,
        healthStatus, e->equipment.controlStatus,
        temperature, power, timestampMs);

    if (equipmentId == selectedEquipmentId_)
        stateLogModel_.markSaved(logId);
}

void EquipmentManager::clearEquipmentStateLogs(QString equipmentId)
{
    DatabaseManager::instance().clearEquipmentEvents(equipmentId);
}

void EquipmentManager::appendStateLog(EquipmentEntry* e, const QString& event,
                                      int temperature, int power)
{
    StateLogEntry le;
    le.logId         = nextLogId_++;
    le.timestampMs   = QDateTime::currentMSecsSinceEpoch();
    le.event         = event;
    le.healthStatus  = e->equipment.healthStatus;
    le.controlStatus = e->equipment.controlStatus;
    le.temperature   = temperature;
    le.power         = power;

    const bool overflow = (e->stateLog.size() >= LOG_BUFFER);
    if (overflow)
        e->stateLog.removeFirst();
    e->stateLog.append(le);

    if (e->equipment.id == selectedEquipmentId_) {
        if (overflow)
            stateLogModel_.removeLast();   // oldest entry sits at end of model
        stateLogModel_.prepend(le);
    }
}

EquipmentManager::EquipmentEntry* EquipmentManager::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it->second.get() : nullptr;
}
