import QtQuick
import QtQuick.Layouts

// 현재 센서값 카드 — Temperature / Power / P(Normal) / P(Abnormal)
Rectangle {
    id: root

    property bool hasData:      false
    property int  label:        -1
    property real temperature:  0.0
    property real power:        0.0
    property real probNormal:   0.0
    property real probAbnormal: 0.0

    radius: 6
    color: "#181a2e"

    GridLayout {
        anchors { fill: parent; margins: 10 }
        columns: 2
        rowSpacing: 6
        columnSpacing: 16

        Text { text: "Temperature"; color: "#7777aa"; font.pixelSize: 11 }
        Text { text: "Power";       color: "#7777aa"; font.pixelSize: 11 }

        Text {
            text: root.hasData ? root.temperature.toFixed(1) + " °C" : "—"
            color: "#66ffaa"; font.pixelSize: 15; font.bold: true
        }
        Text {
            text: root.hasData ? root.power.toFixed(1) + " W" : "—"
            color: "#66aaff"; font.pixelSize: 15; font.bold: true
        }

        Text { text: "P(Normal)";   color: "#7777aa"; font.pixelSize: 11 }
        Text { text: "P(Abnormal)"; color: "#7777aa"; font.pixelSize: 11 }

        Text {
            text: root.label === -1 ? "—" : (root.probNormal   * 100).toFixed(1) + " %"
            color: "#aaddff"; font.pixelSize: 13
        }
        Text {
            text: root.label === -1 ? "—" : (root.probAbnormal * 100).toFixed(1) + " %"
            color: "#ffbb66"; font.pixelSize: 13
        }
    }
}
