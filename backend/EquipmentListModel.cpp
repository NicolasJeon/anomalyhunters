#include "EquipmentListModel.h"

EquipmentListModel::EquipmentListModel(QObject* parent)
    : QAbstractListModel(parent) {}

int EquipmentListModel::rowCount(const QModelIndex&) const
{
    return items_.size();
}

QVariant EquipmentListModel::data(const QModelIndex& index, int role) const
{
    // ── Practice #5: C++ 모델 구현 ────────────────────────────────────────────────
    // Mission: Move equipment ListModel to C++ backend
    // Hints:   data() virtual 함수를 구현하세요

    if (!index.isValid() || index.row() >= items_.size()) return {};
    const auto& eq = items_.at(index.row());
    switch (role) {
    // TODO: role에 맞는 eq의 값을 반환하세요



    
    // ── Practice #5 Answer ───────────────────────────────────────────────────
    // // case NameRole:    return eq.name;
    // // case IpRole:      return eq.ip;
    // // case RunningRole: return eq.running;
    }
    return {};
}

QHash<int, QByteArray> EquipmentListModel::roleNames() const
{
    // ── Practice #5: C++ 모델 구현 ────────────────────────────────────────────────
    // Mission: Move equipment ListModel to C++ backend
    // Hints:   roleNames() virtual 함수를 구현하세요

    return {
    // TODO: QML에서 사용할 role 이름을 등록하세요 (name, ip, running)



    // ── Practice #5 Answer ───────────────────────────────────────────────────
    // // { NameRole,    "name"    },
    // // { IpRole,      "ip"      },
    // // { RunningRole, "running" },
    };
}

void EquipmentListModel::append(const Equipment& eq)
{
    beginInsertRows({}, items_.size(), items_.size());
    items_.append(eq);
    endInsertRows();
}
