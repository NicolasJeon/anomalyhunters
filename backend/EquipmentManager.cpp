#include "EquipmentManager.h"
#include "EquipmentMonitor.h"

#include <cmath>

#include <QDateTime>

// ── 소멸자 ────────────────────────────────────────────────────────────────────
EquipmentManager::~EquipmentManager() = default;

// ── 생성자 ────────────────────────────────────────────────────────────────────
EquipmentManager::EquipmentManager(QObject* parent)
    : QObject(parent)
{
    // DB에서 장비 목록 로드, 없으면 기본값 삽입
    const QVariantList saved = DatabaseManager::instance().loadEquipment();
    if (saved.isEmpty()) {
        addEquipment("Air Circulator", "qrc:/qt/qml/QtFacility/images/air_circulator.png");
        addEquipment("Temp Controller","qrc:/qt/qml/QtFacility/images/temp_controller.png");
        addEquipment("Pump A",         "qrc:/qt/qml/QtFacility/images/pump.png");
        addEquipment("Pump B",         "qrc:/qt/qml/QtFacility/images/pump.png");
        addEquipment("Generator",      "qrc:/qt/qml/QtFacility/images/generator.png");
    } else {
        for (const QVariant& v : saved) {
            const QVariantMap m = v.toMap();
            const QString id    = m["id"].toString();
            const QString name  = m["name"].toString();
            const QString img   = m["imageSource"].toString();

            // nextEquipmentNum_ 복원 — "devN" 형식에서 N 추출
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
            entry->simulator               = DeviceTimeSeriesSimulator(equipmentOrder_.size());

            entry->detector = std::make_unique<AnomalyDetector>();

            equipmentOrder_.append(id);
            entries_.emplace(id, std::move(entry));
        }
        emit equipmentChanged();
    }

    // EquipmentMonitor 생성 및 signal 연결
    monitor_ = std::make_unique<EquipmentMonitor>(*this);
    connect(monitor_.get(), &EquipmentMonitor::equipmentUpdated,
            this, &EquipmentManager::equipmentChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedEquipmentUpdated,
            this, &EquipmentManager::selectedEquipmentChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedTimeSeriesUpdated,
            this, &EquipmentManager::selectedTimeSeriesChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedInferenceUpdated,
            this, &EquipmentManager::selectedInferenceChanged);
    connect(monitor_.get(), &EquipmentMonitor::selectedStateLogsUpdated,
            this, &EquipmentManager::selectedStateLogsChanged);

    // 첫 번째 장비 자동 시작 + 선택
    if (!equipmentOrder_.isEmpty()) {
        startEquipment(equipmentOrder_.first());
        setSelectedEquipmentId(equipmentOrder_.first());
    }
}

// ── Property accessors ────────────────────────────────────────────────────────
QVariantList EquipmentManager::equipment() const
{
    QVariantList list;
    for (const QString& id : equipmentOrder_) {
        if (const EquipmentEntry* e = entryFor(id))
            list.append(e->equipment.toVariantMap());
    }
    return list;
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
    if (!e) return {{"label", -1}, {"abnormalDist", 0.f}, {"statusText", "No Equipment"}};
    return e->inference.toVariantMap();
}

QVariantList EquipmentManager::selectedStateLogs() const
{
    const EquipmentEntry* e = entryFor(selectedEquipmentId_);
    if (!e) return {};

    QVariantList result;
    result.reserve(e->stateLog.size());
    for (int i = e->stateLog.size() - 1; i >= 0; --i)
        result.append(e->stateLog[i].toVariantMap());
    return result;
}

void EquipmentManager::setSelectedEquipmentId(const QString& id)
{
    if (selectedEquipmentId_ == id) return;
    selectedEquipmentId_ = id;
    emit selectedEquipmentChanged();
    emit selectedTimeSeriesChanged();
    emit selectedInferenceChanged();
    emit selectedStateLogsChanged();
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
void EquipmentManager::addEquipment(QString name, QString imageSource)
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
    entry->simulator               = DeviceTimeSeriesSimulator(equipmentOrder_.size());

    entry->detector = std::make_unique<AnomalyDetector>();

    equipmentOrder_.append(id);
    entries_.emplace(id, std::move(entry));

    DatabaseManager::instance().saveNewEquipment(id, name, imageSource);

    emit equipmentChanged();
}

void EquipmentManager::removeEquipment(QString equipmentId)
{
    if (!entries_.count(equipmentId)) return;

    entries_.erase(equipmentId);
    equipmentOrder_.removeAll(equipmentId);

    DatabaseManager::instance().deleteEquipment(equipmentId);
    DatabaseManager::instance().clearEquipmentEvents(equipmentId);

    if (selectedEquipmentId_ == equipmentId) {
        selectedEquipmentId_ = equipmentOrder_.isEmpty() ? QString{} : equipmentOrder_.first();
        emit selectedEquipmentChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
    }

    emit equipmentChanged();
}

void EquipmentManager::updateEquipment(QString equipmentId, QString name, QString imageSource)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e) return;

    e->equipment.name        = name;
    e->equipment.imageSource = imageSource;

    DatabaseManager::instance().updateEquipment(equipmentId, name, imageSource);

    emit equipmentChanged();
    if (equipmentId == selectedEquipmentId_)
        emit selectedEquipmentChanged();
}

// ── Control ───────────────────────────────────────────────────────────────────
void EquipmentManager::startEquipment(QString equipmentId)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e || e->equipment.controlStatus == "Running") return;

    e->equipment.controlStatus = "Running";

    const float curTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
    const float curPower = e->series.isEmpty() ? 0.f : e->series.last().power;

    appendStateLog(e, "start", curTemp, curPower);

    emit equipmentChanged();
    if (equipmentId == selectedEquipmentId_) {
        emit selectedEquipmentChanged();
        emit selectedStateLogsChanged();
    }
}

void EquipmentManager::stopEquipment(QString equipmentId)
{
    EquipmentEntry* e = entryFor(equipmentId);
    if (!e || e->equipment.controlStatus == "Stopped") return;

    e->equipment.controlStatus = "Stopped";

    const float stopTemp  = e->series.isEmpty() ? 0.f : e->series.last().temperature;
    const float stopPower = e->series.isEmpty() ? 0.f : e->series.last().power;

    appendStateLog(e, "stop", stopTemp, stopPower);

    e->equipment.healthStatus = "N/A";
    e->prevHealthStatus       = "N/A";
    e->series.clear();
    e->inference  = InferenceState{};

    emit equipmentChanged();
    if (equipmentId == selectedEquipmentId_) {
        emit selectedEquipmentChanged();
        emit selectedTimeSeriesChanged();
        emit selectedInferenceChanged();
        emit selectedStateLogsChanged();
    }
}

void EquipmentManager::startAll()
{
    for (const QString& id : equipmentOrder_) startEquipment(id);
}

void EquipmentManager::stopAll()
{
    for (const QString& id : equipmentOrder_) stopEquipment(id);
}

// ── Simulation speed (EquipmentMonitor에 위임) ────────────────────────────────
void EquipmentManager::startSimulation() { monitor_->startSimulation(); }
void EquipmentManager::stopSimulation()  { monitor_->stopSimulation(); }

// ── Test with Data (EquipmentMonitor에 위임) ──────────────────────────────────
void EquipmentManager::runTestSeries(QString equipmentId, QVariantList series)
{
    monitor_->runTestSeries(equipmentId, series);
}

void EquipmentManager::clearEquipmentDisplay(QString equipmentId)
{
    monitor_->clearEquipmentDisplay(equipmentId);
}

// ── DB ────────────────────────────────────────────────────────────────────────
QVariantList EquipmentManager::queryEquipmentStateLogs(const QString& equipmentId, int limit) const
{
    return DatabaseManager::instance().queryStateEvents(equipmentId, limit);
}

void EquipmentManager::manualSaveToDb(QString equipmentId, quint64 logId,
                                      float temperature, float power,
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
        emit selectedStateLogsChanged();
}

void EquipmentManager::clearEquipmentStateLogs(QString equipmentId)
{
    DatabaseManager::instance().clearEquipmentEvents(equipmentId);
}

// ── 내부 헬퍼 ─────────────────────────────────────────────────────────────────
void EquipmentManager::appendStateLog(EquipmentEntry* e, const QString& event,
                                      float temperature, float power)
{
    // 소수 1째 자리로 반올림 — 로그와 DB가 항상 동일한 값을 갖도록
    const float roundedTemp  = std::round(temperature * 10.0f) / 10.0f;
    const float roundedPower = std::round(power       * 10.0f) / 10.0f;

    StateLogEntry le;
    le.logId         = nextLogId_++;
    le.timestampMs   = QDateTime::currentMSecsSinceEpoch();
    le.event         = event;
    le.healthStatus  = e->equipment.healthStatus;
    le.controlStatus = e->equipment.controlStatus;
    le.temperature   = roundedTemp;
    le.power         = roundedPower;

    if (e->stateLog.size() >= LOG_BUFFER)
        e->stateLog.removeFirst();
    e->stateLog.append(le);
}

EquipmentManager::EquipmentEntry* EquipmentManager::entryFor(const QString& id) const
{
    auto it = entries_.find(id);
    return (it != entries_.end()) ? it->second.get() : nullptr;
}
