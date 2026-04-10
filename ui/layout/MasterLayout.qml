import QtQuick
import "../components"

// 좌측 MASTER 레이아웃 — 로직/글루 전용
// qmllint disable unqualified
MasterLayoutForm {
    id: root

    equipment:           equipmentManager.equipment
    selectedEquipmentId: equipmentManager.selectedEquipmentId

    // ── 헤더 버튼 ─────────────────────────────────────────────────────────
    btnAdd.onClicked:      equipmentDialog.open("", "", "")
    btnStartAll.onClicked: equipmentManager.startAll()
    btnStopAll.onClicked:  equipmentManager.stopAll()

    // ── 장비 목록 delegate — 시그널 글루 포함 ──────────────────────────────
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
