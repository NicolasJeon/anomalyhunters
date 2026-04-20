#pragma once
#include <QObject>
#include <QtQml/qqmlregistration.h>
#include "EquipmentListModel.h"

// ── Practice #6: C++ 클래스를 QML에 노출 ─────────────────────────────────────
// Mission: Expose C++ class to QML
// Hints:   QML_ELEMENT / QML_SINGLETON 매크로를 추가하세요
//          Q_PROPERTY로 equipmentListModel을 노출하세요

class EquipmentManager : public QObject
{
    Q_OBJECT
    // TODO : EquipmentManager를 QML에 Singleton으로 노출
    // TODO : equipmentListModel 멤버를 Q_PROPERTY로 노출



    // ─────────────────────────────────────────────────────────────────────────
    // ── Practice #6 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    // // QML_ELEMENT
    // // QML_SINGLETON
    // // Q_PROPERTY(EquipmentListModel* equipmentListModel
    // //            READ equipmentListModel CONSTANT)

public:
    explicit EquipmentManager(QObject* parent = nullptr);

    EquipmentListModel* equipmentListModel() { return &model_; }

private:
    EquipmentListModel model_;
};
