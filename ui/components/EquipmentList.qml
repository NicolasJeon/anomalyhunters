import QtQuick
import QtQuick.Controls

ListView {
    anchors.fill: parent
    clip:         true

    // ── Practice #7: 실제 모델 연결 ───────────────────────────────────────────
    // Mission: 더미 ListModel을 EquipmentManager의 실제 모델로 교체하세요
    // Hints:   EquipmentManager.equipmentListModel

    // TODO: model을 EquipmentManager.equipmentListModel 로 교체하세요
    model: ListModel {
        ListElement { name: "Compressor A"; ip: "192.168.0.101"; running: true  }
        ListElement { name: "Compressor B"; ip: "192.168.0.102"; running: false }
        ListElement { name: "Motor X";      ip: "192.168.0.201"; running: true  }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── Practice #7 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    // // model: EquipmentManager.equipmentListModel


    delegate: EquipmentDelegate {
        width: ListView.view.width
    }
}
