#include "StateLogListModel.h"

StateLogListModel::StateLogListModel(QObject* parent)
    : QAbstractListModel(parent) {}

int StateLogListModel::rowCount(const QModelIndex&) const
{
    return items_.size();
}

QVariant StateLogListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= items_.size()) return {};
    const Row& r = items_[index.row()];
    const StateLogEntry& e = r.entry;
    switch (role) {
    case LogIdRole:         return static_cast<qulonglong>(e.logId);
    case TimestampMsRole:   return e.timestampMs;
    case EventRole:         return e.event;
    case HealthStatusRole:  return e.healthStatus;
    case ControlStatusRole: return e.controlStatus;
    case TemperatureRole:   return e.temperature;
    case PowerRole:         return e.power;
    case SavedToDBRole:     return e.savedToDB;
    case FromDBRole:        return r.fromDB;
    }
    return {};
}

QHash<int, QByteArray> StateLogListModel::roleNames() const
{
    return {
        { LogIdRole,         "logId"         },
        { TimestampMsRole,   "timestampMs"   },
        { EventRole,         "event"         },
        { HealthStatusRole,  "healthStatus"  },
        { ControlStatusRole, "controlStatus" },
        { TemperatureRole,   "temperature"   },
        { PowerRole,         "power"         },
        { SavedToDBRole,     "savedToDB"     },
        { FromDBRole,        "fromDB"        }
    };
}

void StateLogListModel::prepend(const StateLogEntry& e)
{
    beginInsertRows({}, 0, 0);
    items_.prepend({e, false});
    endInsertRows();
}

void StateLogListModel::removeLast()
{
    if (items_.isEmpty()) return;
    beginRemoveRows({}, items_.size() - 1, items_.size() - 1);
    items_.removeLast();
    endRemoveRows();
}

void StateLogListModel::setAll(const QVector<StateLogEntry>& entries)
{
    beginResetModel();
    items_.clear();
    for (int i = entries.size() - 1; i >= 0; --i)
        items_.append({entries[i], false});
    endResetModel();
}

void StateLogListModel::setAllFromVariantList(const QVariantList& list)
{
    beginResetModel();
    items_.clear();
    for (const QVariant& v : list) {
        const QVariantMap m = v.toMap();
        StateLogEntry e;
        e.logId         = 0;
        e.timestampMs   = m["timestampMs"].toLongLong();
        e.event         = QString{};
        e.healthStatus  = m["state"].toString();   // DB uses "state"
        e.controlStatus = m["controlStatus"].toString();
        e.temperature   = m["temperature"].toInt();
        e.power         = m["power"].toInt();
        e.savedToDB     = true;
        items_.append({e, true});
    }
    endResetModel();
}

void StateLogListModel::clear()
{
    beginResetModel();
    items_.clear();
    endResetModel();
}

void StateLogListModel::markSaved(quint64 logId)
{
    for (int i = 0; i < items_.size(); ++i) {
        if (items_[i].entry.logId == logId) {
            items_[i].entry.savedToDB = true;
            const auto idx = index(i);
            emit dataChanged(idx, idx, { SavedToDBRole });
            return;
        }
    }
}

QVariantMap StateLogListModel::get(int index) const
{
    if (index < 0 || index >= items_.size()) return {};
    const Row& r = items_[index];
    const StateLogEntry& e = r.entry;
    return {
        { "logId",         static_cast<qulonglong>(e.logId) },
        { "timestampMs",   e.timestampMs   },
        { "event",         e.event         },
        { "healthStatus",  e.healthStatus  },
        { "controlStatus", e.controlStatus },
        { "temperature",   e.temperature   },
        { "power",         e.power         },
        { "savedToDB",     e.savedToDB     },
        { "fromDB",        r.fromDB        }
    };
}
