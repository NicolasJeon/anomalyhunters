import QtQuick
import QtQuick.Controls

// Master / Detail SplitView — 구조/스타일 전용
SplitView {
    id: root

    orientation: Qt.Horizontal

    property alias masterLayout: masterLayout
    property alias detailLayout: detailLayout

    // ── 분할 손잡이 스타일 ─────────────────────────────────────────────────
    handle: Rectangle {
        implicitWidth: 4
        color: SplitHandle.pressed ? "#5599ff"
             : SplitHandle.hovered ? "#2a3a5a"
             : "#1a1c2e"

        Rectangle {
            anchors.centerIn: parent
            width:  2
            height: 32
            radius: 1
            color: SplitHandle.hovered ? "#5599ff" : "#3a4a6a"
        }
    }

    // ── 좌측 ──────────────────────────────────────────────────────────────
    MasterLayout {
        id:                       masterLayout
        SplitView.preferredWidth: 260
        SplitView.minimumWidth:   200
        SplitView.maximumWidth:   420
    }

    // ── 우측 ──────────────────────────────────────────────────────────────
    DetailLayout {
        id:                      detailLayout
        SplitView.fillWidth:     true
        SplitView.minimumWidth:  560
    }
}
