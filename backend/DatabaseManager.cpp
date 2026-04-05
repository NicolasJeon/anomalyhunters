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

    QSqlQuery q;
    const bool ok = q.exec(R"(
        CREATE TABLE IF NOT EXISTS state_events (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id      TEXT    NOT NULL,
            device_name    TEXT    NOT NULL,
            health_status  TEXT    NOT NULL,
            control_status TEXT    NOT NULL,
            temperature    REAL,
            power          REAL,
            label          INTEGER,
            prob_normal    REAL,
            prob_warning   REAL,
            prob_abnormal  REAL,
            recorded_at    INTEGER NOT NULL
        )
    )");

    if (!ok)
        qWarning() << "DatabaseManager: table creation failed:" << q.lastError().text();

    initialized_ = ok;
    return ok;
}

void DatabaseManager::insertStateEvent(
    const QString& deviceId,
    const QString& deviceName,
    const QString& healthStatus,
    const QString& controlStatus,
    float temperature, float power,
    int   label,
    float probNormal, float probWarning, float probAbnormal)
{
    if (!initialized_) return;

    QSqlQuery q;
    q.prepare(R"(
        INSERT INTO state_events
            (device_id, device_name, health_status, control_status,
             temperature, power, label,
             prob_normal, prob_warning, prob_abnormal, recorded_at)
        VALUES
            (:device_id, :device_name, :health_status, :control_status,
             :temperature, :power, :label,
             :prob_normal, :prob_warning, :prob_abnormal, :recorded_at)
    )");

    q.bindValue(":device_id",      deviceId);
    q.bindValue(":device_name",    deviceName);
    q.bindValue(":health_status",  healthStatus);
    q.bindValue(":control_status", controlStatus);
    q.bindValue(":temperature",    temperature);
    q.bindValue(":power",          power);
    q.bindValue(":label",          label);
    q.bindValue(":prob_normal",    probNormal);
    q.bindValue(":prob_warning",   probWarning);
    q.bindValue(":prob_abnormal",  probAbnormal);
    q.bindValue(":recorded_at",    QDateTime::currentMSecsSinceEpoch());

    if (!q.exec())
        qWarning() << "DatabaseManager: insertStateEvent failed:" << q.lastError().text();
}
