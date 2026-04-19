import QtQuick
import QtQuick.Controls

ListView {
    anchors.fill: parent
    clip:         true

    // ── Practice #3: 장비 목록 구성 ───────────────────────────────────────────
    // Mission: ListModel로 장비 목록을 표시하세요
    // Hints:   model: ListModel {
    //              ListElement { name: "장비명"; ip: "192.168.0.x"; running: true }
    //              // ListElement 3개 이상 추가하세요
    //          }
    //          delegate: EquipmentDelegate { width: ListView.view.width }

    // TODO: model과 delegate를 연결하세요



    // ─────────────────────────────────────────────────────────────────────────
    // ── Practice #3 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    // // model: ListModel {
    // //     ListElement { name: "Compressor A"; ip: "192.168.0.101"; running: true  }
    // //     ListElement { name: "Compressor B"; ip: "192.168.0.102"; running: false }
    // //     ListElement { name: "Motor X";      ip: "192.168.0.201"; running: true  }
    // // }
    // //
    // // delegate: EquipmentDelegate {
    // //     width: ListView.view.width
    // // }
}
