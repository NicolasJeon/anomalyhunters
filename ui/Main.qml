import QtQuick
import QtQuick.Controls
import "components"
import "layout"

// equipmentManager 는 main.cpp 에서 setContextProperty("equipmentManager", ...) 로 주입됨
// qmllint disable unqualified
Window {
    id: root

    width:        1280
    height:       720
    minimumWidth: 1280
    minimumHeight: 720
    visible: true
    title:   "Equipment Monitor"
    color:   "#12141f"

    // ── 장비 추가 / 수정 다이얼로그 ───────────────────────────────────────
    EquipmentDialog {
        id: equipmentDialog
        anchors.fill: parent
        z: 100
        onConfirmed: (id, name, img) => {
            if (id === "")
                equipmentManager.addEquipment(name, img)
            else
                equipmentManager.updateEquipment(id, name, img)
        }
    }

    // ── 메인 레이아웃 ─────────────────────────────────────────────────────
    MasterDetailLayout {
        anchors.fill: parent
    }
}
