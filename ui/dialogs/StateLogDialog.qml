import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// DB state log dialog
Popup {
    id: root

    property string equipmentId:   ""
    property string equipmentName: ""

    StateLogListModel { id: dbModel }

    function loadAndOpen() {
        dbModel.setAllFromVariantList(EquipmentManager.queryEquipmentStateLogs(equipmentId))
        open()
    }

    // ── clear confirmation ────────────────────────────────────────────────────
    Popup {
        id: clearConfirmDialog
        modal:            true
        anchors.centerIn: Overlay.overlay
        width:            280
        height:           140
        padding:          0

        background: Rectangle {
            color:        Constant.bgDialog
            radius:       8
            border.color: Constant.danger.border
            border.width: 1
        }

        ColumnLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 12

            Text {
                text:           "Clear All"
                color:          Constant.danger.text
                font.pixelSize: 13
                font.bold:      true
            }
            Text {
                text:           "Delete all DB records for " + root.equipmentName + "."
                color:          Constant.textMuted
                font.pixelSize: 11
                wrapMode:       Text.WordWrap
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                AppButton {
                    Layout.fillWidth:  true
                    implicitHeight:    28
                    label:             "Delete"
                    fontSize:          11
                    bold:              true
                    bgColor:           Constant.danger.bg
                    hoverColor:        Constant.danger.bgHov
                    textColor:         Constant.danger.text
                    borderColor:       Constant.danger.border
                    onClicked: {
                        EquipmentManager.clearEquipmentStateLogs(root.equipmentId)
                        dbModel.clear()
                        clearConfirmDialog.close()
                        toast.show()
                    }
                }
                AppButton {
                    Layout.fillWidth:  true
                    implicitHeight:    28
                    label:             "Cancel"
                    fontSize:          11
                    bgColor:           Constant.cancel.bg
                    hoverColor:        Constant.cancel.bgHov
                    textColor:         Constant.textLabel
                    borderColor:       Constant.border
                    onClicked:         clearConfirmDialog.close()
                }
            }
        }
    }

    // ── success toast ─────────────────────────────────────────────────────────
    Rectangle {
        id:     toast
        parent: Overlay.overlay

        x:      parent ? (parent.width  - width)  / 2 : 0
        y:      parent ? (parent.height - height) - 24 : 0
        width:        160
        height:       30
        radius:       6
        color:        Constant.success.bg
        border.color: Constant.success.border
        border.width: 1
        opacity:      0
        visible:      opacity > 0

        Text {
            anchors.centerIn: parent
            text:             "DB cleared"
            color:            Constant.success.text
            font.pixelSize:   11
        }

        function show() {
            opacity = 1
            hideAnim.restart()
        }

        NumberAnimation {
            id:       hideAnim
            target:   toast
            property: "opacity"
            from:     1; to: 0
            duration: 1500
            easing.type: Easing.InQuad
        }
    }

    // ── size / position ───────────────────────────────────────────────────────
    modal:            true
    anchors.centerIn: Overlay.overlay
    width:            620
    height:           460
    padding:          0

    background: Rectangle {
        color:        Constant.bgDialog
        radius:       8
        border.color: Constant.border
        border.width: 1
    }

    // ── content ───────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing:      0

        // ── header ────────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            implicitHeight:   54

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text:             "DB State Log"
                    color:            Constant.textPrimary
                    font.pixelSize:   17
                    font.bold:        true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text:             root.equipmentName + "  (" + dbModel.count + " records)"
                    color:            Constant.textLabel
                    font.pixelSize:   14
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // ── log list ──────────────────────────────────────────────────────────
        StateLogList {
            Layout.fillWidth:    true
            Layout.fillHeight:   true
            Layout.topMargin:    8
            Layout.bottomMargin: 8
            Layout.leftMargin:   10
            Layout.rightMargin:  10
            model:     dbModel
            emptyText: "No records saved to DB yet"
            fontSize:  2
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // ── footer ────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth:    true
            Layout.topMargin:    10
            Layout.bottomMargin: 10
            Layout.leftMargin:   14
            Layout.rightMargin:  14
            spacing: 8

            AppButton {
                Layout.fillWidth:  true
                implicitHeight:    32
                label:             "Clear All"
                fontSize:          12
                bgColor:           Constant.danger.bg
                hoverColor:        Constant.danger.bgHov
                textColor:         Constant.danger.text
                borderColor:       Constant.danger.border
                onClicked:         clearConfirmDialog.open()
            }

            AppButton {
                Layout.fillWidth:  true
                implicitHeight:    32
                label:             "Cancel"
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
