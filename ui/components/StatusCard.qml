import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string controlStatus: "Stopped"
    property real   temperature:   0.0  // 외부(EquipmentManager)에서 선택된 장비의 온도가 주입됩니다
    property real   power:         0.0  // 외부(EquipmentManager)에서 선택된 장비의 전력이 주입됩니다
    property bool   hasData:       false

    // ── Practice #9: 숫자 변화 애니메이션 ─────────────────────────────────────
    // Mission: temperature / power 값이 바뀔 때 애니메이션을 적용하세요
    // Hints:   Behavior on <property> {
    //              NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    //          }

    // TODO: temperature에 Behavior + NumberAnimation을 추가하세요
    // TODO: power에 Behavior + NumberAnimation을 추가하세요



    // ── Practice #9 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // // Behavior on temperature {
    // //     NumberAnimation {
    // //         duration: 600
    // //         easing.type: Easing.OutCubic
    // //     }
    // // }
    // // Behavior on power {
    // //     NumberAnimation {
    // //         duration: 600
    // //         easing.type: Easing.OutCubic
    // //     }
    // // }

    readonly property real _fs: Math.max(0.55, Math.min(1.4, root.width / 450))

    readonly property color _statusColor: {
        if (root.controlStatus === "Stopped") return Constant.stopped
        return Constant.waiting
    }

    // qmllint disable missing-property
    readonly property color _tempStateColor: Constant.tempStateColor(root.temperature, root.hasData)
    readonly property color _pwrStateColor:  Constant.pwrStateColor(root.power,        root.hasData)
    // qmllint enable missing-property

    radius:       6
    color:        Constant.bgDetail
    border.color: Constant.border
    border.width: 1

    ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text:           "Health Status"
                color:          Constant.textLabel
                font.pixelSize: 16 * root._fs
            }
            RowLayout {
                spacing: 8
                Rectangle {
                    implicitWidth: 10; implicitHeight: 10; radius: 5
                    color: root._statusColor
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
                Text {
                    text:           root.controlStatus === "Stopped" ? "Stopped" : "N/A"
                    color:          root._statusColor
                    font.pixelSize: 19 * root._fs
                    font.bold:      true
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // ── Practice #8: SensorRow에 Temperature / Power 연동 ───────────────
        // Mission: Temperature / Power 값을 SensorRow에 연결하세요
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            SensorRow {
                Layout.fillWidth: true
                iconSource: "qrc:/images/temperature_icon.svg"
                label:      "Temperature"
                valueText:  "—"   // TODO: Math.round(???) + " C"
                valueColor: Constant.sensorTemp
                gaugeRatio: 0     // TODO: Math.min(??? / Constant.gaugeTempMax, 1.0)
                gaugeColor: root._tempStateColor
                fs:         root._fs

                // ── Practice #8 Answer (먼저 직접 해보세요!) ─────────────────
                // // valueText:  Math.round(root.temperature) + " C"
                // // gaugeRatio: Math.min(root.temperature / Constant.gaugeTempMax, 1.0)
            }

            SensorRow {
                Layout.fillWidth: true
                iconSource: "qrc:/images/power_icon.svg"
                label:      "Power"
                valueText:  "—"   // TODO: Math.round(???) + " W"
                valueColor: Constant.sensorPower
                gaugeRatio: 0     // TODO: Math.min(??? / Constant.gaugePwrMax, 1.0)
                gaugeColor: root._pwrStateColor
                fs:         root._fs

                // ── Practice #8 Answer (먼저 직접 해보세요!) ─────────────────
                // // valueText:  Math.round(root.power) + " W"
                // // gaugeRatio: Math.min(root.power / Constant.gaugePwrMax, 1.0)
            }
        }
    }
}
