#pragma once

#include <QString>
#include <QVariantList>

// SQLite event-log manager (singleton, single-threaded)
class DatabaseManager
{
public:
    static DatabaseManager& instance();

    // Call once at startup — opens DB and creates tables
    bool init(const QString& path = "facility.db");

    // Equipment persistence
    QVariantList loadEquipment() const;
    void saveNewEquipment(const QString& id, const QString& name,
                          const QString& imageSource, const QString& ip);
    void deleteEquipment(const QString& id);
    void updateEquipment(const QString& id, const QString& name,
                         const QString& imageSource, const QString& ip);

    // State event log
    QVariantList queryStateEvents(const QString& equipmentId, int limit = 50) const;
    void clearEquipmentEvents(const QString& equipmentId);
    void insertStateEvent(
        const QString& equipmentId,
        const QString& equipmentName,
        const QString& state,
        const QString& controlStatus,
        int temperature,
        int power,
        qint64 timestampMs
    );

private:
    DatabaseManager() = default;
    bool initialized_ = false;
};
