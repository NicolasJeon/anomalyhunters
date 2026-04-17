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
    const auto& e = items_[index.row()];
    switch (role) {
    case IdRole:            return e.id;
    case NameRole:          return e.name;
    case HealthStatusRole:  return e.healthStatus;
    case ControlStatusRole: return e.controlStatus;
    case ImageSourceRole:   return e.imageSource;
    case IpRole:            return e.ip;
    }
    return {};
}

QHash<int, QByteArray> EquipmentListModel::roleNames() const
{
    return {
        { IdRole,            "id"            },
        { NameRole,          "name"          },
        { HealthStatusRole,  "healthStatus"  },
        { ControlStatusRole, "controlStatus" },
        { ImageSourceRole,   "imageSource"   },
        { IpRole,            "ip"            }
    };
}

void EquipmentListModel::append(const Equipment& eq)
{
    beginInsertRows({}, items_.size(), items_.size());
    items_.append(eq);
    endInsertRows();
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

void EquipmentListModel::update(const QString& id, const QString& name,
                                const QString& imageSource, const QString& ip)
{
    for (int i = 0; i < items_.size(); ++i) {
        if (items_[i].id == id) {
            items_[i].name        = name;
            items_[i].imageSource = imageSource;
            items_[i].ip          = ip;
            const auto idx = index(i);
            emit dataChanged(idx, idx, { NameRole, ImageSourceRole, IpRole });
            return;
        }
    }
}

void EquipmentListModel::updateStatus(const QString& id, const QString& healthStatus,
                                      const QString& controlStatus)
{
    for (int i = 0; i < items_.size(); ++i) {
        if (items_[i].id == id) {
            items_[i].healthStatus  = healthStatus;
            items_[i].controlStatus = controlStatus;
            const auto idx = index(i);
            emit dataChanged(idx, idx, { HealthStatusRole, ControlStatusRole });
            return;
        }
    }
}
