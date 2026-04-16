pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// Manual DB save dialog
Popup {
    id: root

    property string equipmentId:   ""
    property string equipmentName: ""
    property real   temperature:   0
    property real   power:         0
    property string healthStatus:  ""
    property var    logId:         0

    function open() { root.visible = true }

    // ── size / position ───────────────────────────────────────────────────────
    modal:            true
    focus:            true
    anchors.centerIn: Overlay.overlay

    onOpened: saveBtn.forceActiveFocus()
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
        anchors { fill: parent; margins: 14 }
        spacing: 10

        // ── header ────────────────────────────────────────────────────────────
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

        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   1
            color:            Constant.border
        }

        // ── temp / power (read-only) ──────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 4

            Text { text: "Temperature (°C)"; color: Constant.textLabel; font.pixelSize: 12 }
            Text { text: Math.round(root.temperature); color: "#e0e0f8"; font.pixelSize: 13; font.family: "Courier New" }

            Text { text: "Power (W)"; color: Constant.textLabel; font.pixelSize: 12 }
            Text { text: Math.round(root.power); color: "#e0e0f8"; font.pixelSize: 13; font.family: "Courier New" }
        }

        // ── status (read-only) ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text { text: "Status"; color: Constant.textLabel; font.pixelSize: 12 }
            Text {
                text:           root.healthStatus.toUpperCase()
                color:          Constant.healthColor(root.healthStatus)
                font.pixelSize: 13
                font.bold:      true
            }
        }

        // ── save / close ──────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppButton {
                id:                saveBtn
                Layout.fillWidth:  true
                implicitHeight:    30
                label:             "Save"
                fontSize:          12
                bold:              true
                bgColor:           Constant.success.bg
                hoverColor:        Constant.success.bgHov
                textColor:         Constant.success.text
                borderColor:       Constant.success.border

                function doSave() {
                    // qmllint disable unqualified
                    equipmentManager.manualSaveToDb(root.equipmentId, root.logId,
                                                    root.temperature, root.power,
                                                    root.healthStatus)
                    root.close()
                }
                onClicked:            doSave()
                Keys.onReturnPressed: doSave()
                Keys.onEnterPressed:  doSave()
            }

            AppButton {
                Layout.fillWidth:  true
                implicitHeight:    30
                label:             "Close"
                fontSize:          12
                bgColor:           Constant.cancel.bg
                hoverColor:        Constant.cancel.bgHov
                textColor:         Constant.textLabel
                borderColor:       Constant.border
                onClicked:         root.close()
            }
        }
    }
}
