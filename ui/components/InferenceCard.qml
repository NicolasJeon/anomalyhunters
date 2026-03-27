import QtQuick
import QtQuick.Layouts

// 추론 결과 카드 — 상태 배너 + P(Abnormal) 게이지
// controlStatus: "stopped" | "running" | "emergency"
Rectangle {
    id: root

    property string controlStatus: "stopped"
    property int    label:         -1
    property string statusText:    "—"
    property real   probAbnormal:  0.0

    radius: 6
    color: "#181a2e"

    function bannerColor() {
        if (root.controlStatus === "emergency") return "#5a0000"
        if (root.label === -1) return "#444466"
        if (root.label ===  0) return "#1a7a4a"
        return "#9b2335"
    }

    ColumnLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 8

        // 상태 배너
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 5
            color: root.bannerColor()
            Behavior on color { ColorAnimation { duration: 250 } }

            Text {
                anchors.centerIn: parent
                text: root.controlStatus === "emergency" ? "⚠  EMERGENCY STOP"
                                                         : root.statusText
                color: root.controlStatus === "emergency" ? "#ff9944" : "white"
                font.pixelSize: root.controlStatus === "emergency" ? 14 : 18
                font.bold: true
            }
        }

        // P(Abnormal) 게이지
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text { text: "Anomaly Probability"; color: "#7777aa"; font.pixelSize: 10 }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 12
                radius: 3; color: "#0e1020"

                Rectangle {
                    width: parent.width * root.probAbnormal
                    height: parent.height; radius: 3
                    color: {
                        if (root.probAbnormal < 0.4) return "#1a7a4a"
                        if (root.probAbnormal < 0.7) return "#c87941"
                        return "#9b2335"
                    }
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }
        }
    }
}
