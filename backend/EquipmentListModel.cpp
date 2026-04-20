#include "EquipmentListModel.h"

EquipmentListModel::EquipmentListModel(QObject* parent)
    : QAbstractListModel(parent) {}

int EquipmentListModel::rowCount(const QModelIndex&) const
{
    return items_.size();
}

QVariant EquipmentListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= items_.size()) return {};
    const auto& eq = items_.at(index.row());
    switch (role) {
    case IdRole:          return eq.id;
    case NameRole:        return eq.name;
    case IpRole:          return eq.ip;
    case ImageSourceRole: return eq.imageSource;
    case RunningRole:     return eq.running;
    }
    return {};
}

QHash<int, QByteArray> EquipmentListModel::roleNames() const
{
    return {
        { IdRole,          "id"          },
        { NameRole,        "name"        },
        { IpRole,          "ip"          },
        { ImageSourceRole, "imageSource" },
        { RunningRole,     "running"     },
    };
}

void EquipmentListModel::append(const Equipment& eq)
{
    beginInsertRows({}, items_.size(), items_.size());
    items_.append(eq);
    endInsertRows();
}

Equipment EquipmentListModel::find(const QString& id) const
{
    for (const auto& eq : items_)
        if (eq.id == id) return eq;
    return {};
}

QString EquipmentListModel::find_first_id() const
{
    return items_.isEmpty() ? QString{} : items_.first().id;
}

void EquipmentListModel::remove(const QString& id)
{
    for (int i = 0; i < items_.size(); ++i) {
        if (items_[i].id == id) {
            beginRemoveRows({}, i, i);
            items_.removeAt(i);
            endRemoveRows();
            return;
        }
    }
}
