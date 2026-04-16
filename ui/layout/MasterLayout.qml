import QtQuick
import "../components"

// Master panel — logic glue
// qmllint disable unqualified
MasterLayoutForm {
    id: root

    equipment:           equipmentManager.equipment
    selectedEquipmentId: equipmentManager.selectedEquipmentId

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
    btnStartAll.onClicked: equipmentManager.startAll()
    btnStopAll.onClicked:  equipmentManager.stopAll()

    // ── list delegate ──
    equipmentList.delegate: EquipmentListItem {
        required property var modelData
        width:         ListView.view.width
        equipmentData: modelData
        isSelected:    modelData["id"] === root.selectedEquipmentId

        onSelected:        equipmentManager.selectedEquipmentId = modelData["id"]
        onStartRequested:  equipmentManager.startEquipment(modelData["id"])
        onStopRequested:   equipmentManager.stopEquipment(modelData["id"])
        onDeleteRequested: equipmentManager.removeEquipment(modelData["id"])
    }
}
