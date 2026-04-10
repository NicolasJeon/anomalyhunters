pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// 수동 DB 저장 팝업
// 사용 예)
//   ManualSaveDialog { id: dlg; equipmentId: "..."; equipmentName: "Pump A" }
//   dlg.open()
Popup {
    id: root

    property string equipmentId:   ""
    property string equipmentName: ""
    property real   temperature:   0
    property real   power:         0
    property string healthStatus:  ""
    property var    logId:         0

    function open() { root.visible = true }

    // ── 팝업 위치·크기 ────────────────────────────────────────────────────────
    modal:            true
    anchors.centerIn: Overlay.overlay
    width:            300
    height:           190
    padding:          0

    background: Rectangle {
        color:        Constant.bgDialog
        radius:       8
        border.color: Constant.border
        border.width: 1
    }

    ColumnLayout {
        anchors {
            fill:    parent
            margins: 14
        }
        spacing: 10

        // ── 헤더 행 ────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text:           "Save to DB"
                color:          Constant.textLabel
                font.pixelSize: 14
                font.bold:      true
            }
            Text {
                text:           "— " + root.equipmentName
                color:          Constant.textMuted
                font.pixelSize: 13
            }
        }

        // ── 구분선 ──────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   1
            color:            Constant.border
        }

        // ── 온도 / 전력 표시 (읽기 전용) ──────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 4

            Text {
                text:           "Temperature (°C)"
                color:          Constant.textLabel
                font.pixelSize: 12
            }
            Text {
                text:           root.temperature.toFixed(1)
                color:          "#e0e0f8"
                font.pixelSize: 13
                font.family:    "Courier New"
            }

            Text {
                text:           "Power (W)"
                color:          Constant.textLabel
                font.pixelSize: 12
            }
            Text {
                text:           root.power.toFixed(1)
                color:          "#e0e0f8"
                font.pixelSize: 13
                font.family:    "Courier New"
            }
        }

        // ── 상태 표시 (읽기 전용) ─────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text:           "Status"
                color:          Constant.textLabel
                font.pixelSize: 12
            }
            Text {
                text:  root.healthStatus.toUpperCase()
                color: Constant.healthColor(root.healthStatus)
                font.pixelSize: 13
                font.bold:      true
            }
        }

        // ── 저장 / 닫기 버튼 ──────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppButton {
                Layout.fillWidth:  true
                implicitHeight:    30
                label:             "Save"
                fontSize:          12
                bold:              true
                bgColor:           Constant.successBg
                hoverColor:        Constant.successBgHov
                textColor:         Constant.successText
                borderColor:       Constant.successBorder

                onClicked: {
                    // qmllint disable unqualified
                    equipmentManager.manualSaveToDb(root.equipmentId, root.logId,
                                                    root.temperature, root.power,
                                                    root.healthStatus)
                    root.close()
                }
            }

            AppButton {
                Layout.fillWidth:  true
                implicitHeight:    30
                label:             "Close"
                fontSize:          12
                bgColor:           "#1a1a2e"
                hoverColor:        "#2a1a2e"
                textColor:         Constant.textLabel
                borderColor:       Constant.border
                onClicked:         root.close()
            }
        }
    }
}
