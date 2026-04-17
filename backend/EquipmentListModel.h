#pragma once

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "Equipment.h"

// QAbstractListModel for equipment list
// Exposes each Equipment field as a named role
class EquipmentListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        IdRole = Qt::UserRole,
        NameRole,
        HealthStatusRole,
        ControlStatusRole,
        ImageSourceRole,
        IpRole
    };

    explicit EquipmentListModel(QObject* parent = nullptr);

    int     rowCount(const QModelIndex& = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void append(const Equipment& eq);
    void remove(const QString& id);
    void update(const QString& id, const QString& name,
                const QString& imageSource, const QString& ip);
    void updateStatus(const QString& id, const QString& healthStatus,
                      const QString& controlStatus);

    const QList<Equipment>& items() const { return items_; }

private:
    QList<Equipment> items_;
};
