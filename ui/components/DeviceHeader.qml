import QtQuick
import QtQuick.Layouts

// 상세 패널 헤더 — 장비 이름/타입 + 상태별 제어 버튼
// controlStatus: "stopped" | "running" | "emergency"
RowLayout {
    id: root

    property string name:          ""
    property string type:          ""
    property string controlStatus: "stopped"

    signal startRequested()
    signal stopRequested()
    signal emergencyRequested()
    signal resetRequested()
    signal editRequested()

    spacing: 10

    Column {
        spacing: 2
        Text {
            text: root.name
            color: "#e0e0f8"; font.pixelSize: 18; font.bold: true
        }
        Text {
            text: root.type
            color: "#666688"; font.pixelSize: 12
        }
    }

    Item { Layout.fillWidth: true }

    // ── 편집 버튼 ────────────────────────────────────────────────────────
    Rectangle {
        implicitWidth: 64; implicitHeight: 30; radius: 4
        color: editMouse.containsMouse ? "#253050" : "#1a2035"
        border.color: editMouse.containsMouse ? "#5599ff" : "#2a3a5a"; border.width: 1
        Text { anchors.centerIn: parent; text: "✎  Edit"; color: editMouse.containsMouse ? "#88aaff" : "#6688bb"; font.pixelSize: 11 }
        MouseArea { id: editMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.editRequested() }
    }

    // ── stopped → [▶ Start] ──────────────────────────────────────────────
    Rectangle {
        visible: root.controlStatus === "stopped"
        implicitWidth: 80; implicitHeight: 30; radius: 4
        color: startMouse.containsMouse ? "#1a5a1a" : "#1a4a1a"

        Text { anchors.centerIn: parent; text: "▶  Start"; color: "#77ff77"; font.pixelSize: 12 }
        MouseArea { id: startMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.startRequested() }
    }

    // ── running → [⏹ Stop] [⚠ Emergency] ───────────────────────────────
    Rectangle {
        visible: root.controlStatus === "running"
        implicitWidth: 70; implicitHeight: 30; radius: 4
        color: stopMouse.containsMouse ? "#6a1a1a" : "#5a1a1a"

        Text { anchors.centerIn: parent; text: "⏹  Stop"; color: "#ff7777"; font.pixelSize: 12 }
        MouseArea { id: stopMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.stopRequested() }
    }

    Rectangle {
        visible: root.controlStatus === "running"
        implicitWidth: 80; implicitHeight: 30; radius: 4
        color: emgMouse.containsMouse ? "#5a2000" : "#1a1a1a"
        border.color: emgMouse.containsMouse ? "#ff6600" : "#3a3a4a"; border.width: 1

        Text { anchors.centerIn: parent; text: "E-Stop"; color: emgMouse.containsMouse ? "#ff9944" : "#888899"; font.pixelSize: 12 }
        MouseArea { id: emgMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.emergencyRequested() }
    }

    // ── emergency → [↺ Reset] ────────────────────────────────────────────
    Rectangle {
        visible: root.controlStatus === "emergency"
        implicitWidth: 80; implicitHeight: 30; radius: 4
        color: resetMouse.containsMouse ? "#2a2a6a" : "#1a1a5a"
        border.color: "#5555cc"; border.width: 1

        Text { anchors.centerIn: parent; text: "↺  Reset"; color: "#aaaaff"; font.pixelSize: 12 }
        MouseArea { id: resetMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.resetRequested() }
    }
}
