import QtQuick
import QtQuick.Controls

// qmllint disable unqualified missing-property
ListView {
    clip: true

    model: EquipmentManager.equipmentListModel

    delegate: EquipmentDelegate {
        width:      ListView.view.width
        isSelected: model.id === EquipmentManager.selectedEquipmentId
        onSelected:        EquipmentManager.selectedEquipmentId = model.id
        onDeleteRequested: (id) => EquipmentManager.removeEquipment(id)
    }

    // ── Practice #10: 목록 애니메이션 ────────────────────────────────────────
    // Mission: 장비가 추가/제거될 때 슬라이드 애니메이션을 적용하세요
    // Hints:   Transition + NumberAnimation을 사용하세요
    //          property: "x"
    //          add    → from: -width, to: 0
    //          remove → to: -width

    // TODO: add / remove Transition을 추가하세요
    


    // ── Practice #10 Answer (먼저 직접 해보세요!) ─────────────────────────────
    // // add: Transition {
    // //     NumberAnimation { property: "x"; from: -width; to: 0; duration: 280; easing.type: Easing.OutCubic }
    // // }
    // // remove: Transition {
    // //     NumberAnimation { property: "x"; to: -width; duration: 250; easing.type: Easing.InCubic }
    // // }
}
