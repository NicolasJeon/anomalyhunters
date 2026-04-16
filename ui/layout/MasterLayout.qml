import QtQuick
import "../components"

// Master panel — logic glue

MasterLayoutForm {
    id: root

    equipment:           EquipmentManager.equipment
    selectedEquipmentId: EquipmentManager.selectedEquipmentId

    // ── status counts ──
    readonly property var _counts: {
        let n = 0, w = 0, a = 0
        for (const eq of equipment) {
            const h = eq["healthStatus"] ?? ""
            if      (h === "Normal")   n++
            else if (h === "Warning")  w++
            else if (h === "Abnormal") a++
        }
        return { normal: n, warning: w, abnormal: a }
    }
    countTotal:    equipment.length
    countNormal:   _counts.normal
    countWarning:  _counts.warning
    countAbnormal: _counts.abnormal

    // ── header buttons ──
    btnAdd.onClicked:      equipmentDialog.open("", "", "", "")
    btnStartAll.onClicked: EquipmentManager.startAll()
    btnStopAll.onClicked:  EquipmentManager.stopAll()

    // ── list delegate ──
    equipmentList.delegate: EquipmentListItem {
        required property var modelData
        width:         ListView.view.width
        equipmentData: modelData
        isSelected:    modelData["id"] === root.selectedEquipmentId

        onSelected:        EquipmentManager.selectedEquipmentId = modelData["id"]
        onStartRequested:  EquipmentManager.startEquipment(modelData["id"])
        onStopRequested:   EquipmentManager.stopEquipment(modelData["id"])
        onDeleteRequested: EquipmentManager.removeEquipment(modelData["id"])
    }
}
