import QtQuick
import QtQuick.Layouts

// 통합 상태 카드 — 상태+게이지 한 줄 / 센서 수치
Rectangle {
    id: root

    property string controlStatus: "stopped"
    property int    label:         -1
    property string statusText:    "—"
    property real   probNormal:    0.0
    property real   probWarning:   0.0
    property real   probAbnormal:  0.0
    property bool   hasData:       false
    property real   temperature:   0.0
    property real   power:         0.0

    radius: 6
    color: "#181a2e"

    function statusColor() {
        if (root.controlStatus === "emergency") return "#ff4400"
        if (root.label === -1) return "#555577"
        if (root.label ===  0) return "#22aa66"
        if (root.label ===  1) return "#c87941"
        return "#cc3344"
    }

    // warning 시 우측 바 주황, 그 외 빨강
    function rightBarColor() {
        if (root.label === 1) return "#c87941"
        return "#9b2335"
    }

    ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 10

        // ── ① 상태 텍스트 ─────────────────────────────────────────────────
        RowLayout {
            spacing: 8
            Rectangle {
                implicitWidth: 8; implicitHeight: 8; radius: 4
                color: root.statusColor()
                Behavior on color { ColorAnimation { duration: 250 } }
            }
            Text {
                text: root.controlStatus === "emergency" ? "EMERGENCY STOP" : root.statusText
                color: root.statusColor()
                font.pixelSize: 14; font.bold: true
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        // ── ② 경쟁 게이지: N% [녹|주황|적] W% A% ────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            // N%
            Text {
                text: root.label === -1 ? "—" : (root.probNormal * 100).toFixed(0) + "%"
                color: "#22aa66"; font.pixelSize: 11; font.bold: true
            }

            // 3구간 바
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 8; radius: 3; color: "#0e1020"

                // Normal — 좌측
                Rectangle {
                    anchors.left: parent.left
                    width: parent.width * root.probNormal
                    height: parent.height; radius: 3
                    color: "#1a7a4a"
                    Behavior on width { NumberAnimation { duration: 200 } }
                }

                // Warning — Normal 바로 우측
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * root.probNormal
                    width: parent.width * root.probWarning
                    height: parent.height
                    color: "#c87941"
                    Behavior on width { NumberAnimation { duration: 200 } }
                    Behavior on anchors.leftMargin { NumberAnimation { duration: 200 } }
                }

                // Abnormal — 우측
                Rectangle {
                    anchors.right: parent.right
                    width: parent.width * root.probAbnormal
                    height: parent.height; radius: 3
                    color: "#9b2335"
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }

            // W%
            Text {
                text: root.label === -1 ? "—" : (root.probWarning * 100).toFixed(0) + "%"
                color: "#c87941"; font.pixelSize: 11; font.bold: true
            }

            // A%
            Text {
                text: root.label === -1 ? "—" : (root.probAbnormal * 100).toFixed(0) + "%"
                color: root.rightBarColor(); font.pixelSize: 11; font.bold: true
            }
        }

        // ── 구분선 ────────────────────────────────────────────────────────
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#2a2c4e" }

        // ── ③ 센서 수치 ───────────────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 5
            columnSpacing: 0
            rowSpacing: 4

            Text { text: "Temperature";  color: "#7777aa"; font.pixelSize: 10; Layout.fillWidth: true }
            Text { text: "Power";        color: "#7777aa"; font.pixelSize: 10; Layout.fillWidth: true }
            Text { text: "P(Normal)";    color: "#7777aa"; font.pixelSize: 10; Layout.fillWidth: true }
            Text { text: "P(Warning)";   color: "#7777aa"; font.pixelSize: 10; Layout.fillWidth: true }
            Text { text: "P(Abnormal)";  color: "#7777aa"; font.pixelSize: 10; Layout.fillWidth: true }

            Text {
                text: root.hasData ? root.temperature.toFixed(1) + " °C" : "—"
                color: "#66ffaa"; font.pixelSize: 14; font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: root.hasData ? root.power.toFixed(1) + " W" : "—"
                color: "#66aaff"; font.pixelSize: 14; font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: root.label === -1 ? "—" : (root.probNormal  * 100).toFixed(1) + " %"
                color: "#22aa66"; font.pixelSize: 13; font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: root.label === -1 ? "—" : (root.probWarning * 100).toFixed(1) + " %"
                color: "#c87941"; font.pixelSize: 13; font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: root.label === -1 ? "—" : (root.probAbnormal * 100).toFixed(1) + " %"
                color: "#9b2335"; font.pixelSize: 13; font.bold: true
                Layout.fillWidth: true
            }
        }
    }
}
