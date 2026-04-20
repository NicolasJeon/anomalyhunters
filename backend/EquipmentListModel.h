#pragma once
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "Equipment.h"

// ── Practice #5 참고 ─────────────────────────────────────────────────────────
// EquipmentListModel은 QAbstractListModel을 상속합니다
//
// QAbstractListModel은 QML ListView에 데이터를 제공하는 추상 클래스입니다
// 상속 시 반드시 구현해야 하는 virtual 함수(override)가 3개 있습니다:
//   - rowCount()  : 항목 개수 반환          → 이미 구현되어 있습니다
//   - data()      : 각 항목의 데이터를 role에 따라 반환  → Practice #5
//   - roleNames() : QML에서 사용할 role 이름을 등록     → Practice #5
// 구현은 EquipmentListModel.cpp 에서 하세요

class EquipmentListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles { NameRole = Qt::UserRole, IpRole, RunningRole };

    explicit EquipmentListModel(QObject* parent = nullptr);

    int      rowCount(const QModelIndex& = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void append(const Equipment& eq);

private:
    QList<Equipment> items_;
};
