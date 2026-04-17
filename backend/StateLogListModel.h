#pragma once

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "Equipment.h"

// QAbstractListModel for state log — newest entry first (prepend)
// Used by both StateLogPanel (in-memory) and StateLogDialog (DB)
class StateLogListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        LogIdRole = Qt::UserRole,
        TimestampMsRole,
        EventRole,
        HealthStatusRole,
        ControlStatusRole,
        TemperatureRole,
        PowerRole,
        SavedToDBRole,
        FromDBRole
    };

    explicit StateLogListModel(QObject* parent = nullptr);

    int      rowCount(const QModelIndex& = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    // In-memory: prepend new entry (newest first)
    void prepend(const StateLogEntry& e);
    void removeLast();

    // Full reset — in-memory (reversed to newest-first)
    void setAll(const QVector<StateLogEntry>& entries);

    // Full reset — DB query results (state → healthStatus, fromDB=true)
    Q_INVOKABLE void setAllFromVariantList(const QVariantList& list);

    Q_INVOKABLE void clear();
    void markSaved(quint64 logId);

    // Returns row data as QVariantMap for QML delegate actions
    Q_INVOKABLE QVariantMap get(int index) const;

private:
    struct Row {
        StateLogEntry entry;
        bool fromDB = false;
    };
    QList<Row> items_;
};
