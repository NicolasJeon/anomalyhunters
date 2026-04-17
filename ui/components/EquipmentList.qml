import QtQuick
import QtFacility

// Equipment list — self-contained: model, delegate, transitions all wired internally
ListView {
    id: root

    model: EquipmentManager.equipmentListModel
    clip:  true

    delegate: EquipmentDelegate {
        width:         ListView.view.width
        equipmentData: ({
            id:            model.id,
            name:          model.name,
            healthStatus:  model.healthStatus,
            controlStatus: model.controlStatus,
            imageSource:   model.imageSource,
            ip:            model.ip
        })
        isSelected: model.id === EquipmentManager.selectedEquipmentId

        onSelected:        EquipmentManager.selectedEquipmentId = model.id
        onStartRequested:  EquipmentManager.startEquipment(model.id)
        onStopRequested:   EquipmentManager.stopEquipment(model.id)
        onDeleteRequested: EquipmentManager.removeEquipment(model.id)
    }

    add: Transition {
        NumberAnimation { property: "x"; from: 80; to: 0; duration: 280; easing.type: Easing.OutCubic }
    }

    remove: Transition {
        NumberAnimation { property: "x"; to: -80; duration: 250; easing.type: Easing.InCubic }
    }

    removeDisplaced: Transition {
        NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutCubic }
    }
}
