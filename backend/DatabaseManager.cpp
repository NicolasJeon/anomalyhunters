#include "DatabaseManager.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>

DatabaseManager& DatabaseManager::instance()
{
    static DatabaseManager inst;
    return inst;
}

bool DatabaseManager::init(const QString& path)
{
    if (initialized_) return true;

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    if (!db.open()) {
        qWarning() << "DatabaseManager: DB open failed:" << db.lastError().text();
        return false;
    }

    QSqlQuery pragma;
    pragma.exec("PRAGMA journal_mode=DELETE");
    pragma.exec("PRAGMA synchronous=FULL");

    // Schema v2: drop old table if it has the legacy 'event' column
    {
        QSqlQuery check;
        check.exec("PRAGMA table_info(state_events)");
        bool hasEventCol = false;
        bool tableExists = false;
        while (check.next()) {
            tableExists = true;
            if (check.value(1).toString() == "event")
                hasEventCol = true;
        }
        if (tableExists && hasEventCol) {
            QSqlQuery drop;
            drop.exec("DROP TABLE IF EXISTS state_events");
            qDebug() << "DatabaseManager: migrated schema — old table dropped";
        }
    }

    // ── devices 테이블 ──────────────────────────────────────────────────────
    {
        QSqlQuery q;
        q.exec(R"(
            CREATE TABLE IF NOT EXISTS devices (
                id           TEXT    PRIMARY KEY,
                name         TEXT    NOT NULL,
                image_source TEXT    NOT NULL DEFAULT '',
                order_index  INTEGER NOT NULL DEFAULT 0
            )
        )");
    }

    // ── state_events 테이블 ─────────────────────────────────────────────────
    QSqlQuery q;
    const bool ok = q.exec(R"(
        CREATE TABLE IF NOT EXISTS state_events (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id      TEXT    NOT NULL,
            device_name    TEXT    NOT NULL,
            state          TEXT    NOT NULL,
            control_status TEXT    NOT NULL,
            temperature    REAL,
            power          REAL,
            recorded_at    INTEGER NOT NULL
        )
    )");

    if (!ok)
        qWarning() << "DatabaseManager: table creation failed:" << q.lastError().text();

    initialized_ = ok;
    return ok;
}

// ── Equipment persistence ─────────────────────────────────────────────────────
QVariantList DatabaseManager::loadEquipment() const
{
    if (!initialized_) return {};

    QSqlQuery q;
    q.exec("SELECT id, name, image_source FROM devices ORDER BY order_index ASC");

    QVariantList result;
    while (q.next()) {
        QVariantMap m;
        m["id"]          = q.value(0).toString();
        m["name"]        = q.value(1).toString();
        m["imageSource"] = q.value(2).toString();
        result.append(m);
    }
    return result;
}

void DatabaseManager::saveNewEquipment(const QString& id, const QString& name,
                                       const QString& imageSource)
{
    if (!initialized_) return;

    QSqlQuery maxQ;
    maxQ.exec("SELECT COALESCE(MAX(order_index), -1) FROM devices");
    int nextOrder = maxQ.next() ? maxQ.value(0).toInt() + 1 : 0;

    QSqlQuery q;
    q.prepare("INSERT OR REPLACE INTO devices (id, name, image_source, order_index) "
              "VALUES (:id, :name, :img, :ord)");
    q.bindValue(":id",   id);
    q.bindValue(":name", name);
    q.bindValue(":img",  imageSource);
    q.bindValue(":ord",  nextOrder);
    if (!q.exec())
        qWarning() << "DatabaseManager: saveNewEquipment failed:" << q.lastError().text();
}

void DatabaseManager::deleteEquipment(const QString& id)
{
    if (!initialized_) return;

    QSqlQuery q;
    q.prepare("DELETE FROM devices WHERE id = :id");
    q.bindValue(":id", id);
    if (!q.exec())
        qWarning() << "DatabaseManager: deleteEquipment failed:" << q.lastError().text();
}

void DatabaseManager::updateEquipment(const QString& id, const QString& name,
                                      const QString& imageSource)
{
    if (!initialized_) return;

    QSqlQuery q;
    q.prepare("UPDATE devices SET name = :name, image_source = :img WHERE id = :id");
    q.bindValue(":name", name);
    q.bindValue(":img",  imageSource);
    q.bindValue(":id",   id);
    if (!q.exec())
        qWarning() << "DatabaseManager: updateEquipment failed:" << q.lastError().text();
}

QVariantList DatabaseManager::queryStateEvents(const QString& equipmentId, int limit) const
{
    if (!initialized_) return {};

    QSqlQuery q;
    q.prepare(R"(
        SELECT recorded_at, state, control_status, temperature, power
        FROM state_events
        WHERE device_id = :device_id
        ORDER BY recorded_at DESC
        LIMIT :limit
    )");
    q.bindValue(":device_id", equipmentId);
    q.bindValue(":limit", limit);

    QVariantList result;
    if (q.exec()) {
        while (q.next()) {
            QVariantMap entry;
            entry["timestampMs"]   = q.value(0).toLongLong();
            entry["state"]         = q.value(1).toString();
            entry["controlStatus"] = q.value(2).toString();
            entry["temperature"]   = q.value(3).toFloat();
            entry["power"]         = q.value(4).toFloat();
            entry["fromDB"]        = true;
            result.append(entry);
        }
    } else {
        qWarning() << "DatabaseManager: queryStateEvents failed:" << q.lastError().text();
    }
    return result;
}

void DatabaseManager::clearEquipmentEvents(const QString& equipmentId)
{
    if (!initialized_) return;

    QSqlQuery q;
    q.prepare("DELETE FROM state_events WHERE device_id = :device_id");
    q.bindValue(":device_id", equipmentId);

    if (!q.exec())
        qWarning() << "DatabaseManager: clearEquipmentEvents failed:" << q.lastError().text();
}

void DatabaseManager::insertStateEvent(
    const QString& equipmentId,
    const QString& equipmentName,
    const QString& state,
    const QString& controlStatus,
    float temperature,
    float power,
    qint64 timestampMs)
{
    if (!initialized_) return;

    QSqlQuery q;
    q.prepare(R"(
        INSERT INTO state_events
            (device_id, device_name, state, control_status, temperature, power, recorded_at)
        VALUES
            (:device_id, :device_name, :state, :control_status, :temperature, :power, :recorded_at)
    )");

    q.bindValue(":device_id",      equipmentId);
    q.bindValue(":device_name",    equipmentName);
    q.bindValue(":state",          state);
    q.bindValue(":control_status", controlStatus);
    q.bindValue(":temperature",    temperature);
    q.bindValue(":power",          power);
    q.bindValue(":recorded_at",    timestampMs);

    if (!q.exec())
        qWarning() << "DatabaseManager: insertStateEvent failed:" << q.lastError().text();
}
