import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtFacility

// Add / Edit equipment dialog
// open("", "", "", "") — add mode; open(id, ...) — edit mode
// confirmed: id == "" → add, else → update
Rectangle {
    id: root

    property bool   editMode:    false
    property string equipmentId: ""
    property string imgSource:   ""

    signal confirmed(string equipmentId, string name, string imgSource, string ip)

    visible: false
    color: Constant.bgOverlay

    // ── open / close ──────────────────────────────────────────────────────────
    function open(id, name, img, ip) {
        equipmentId    = id
        editMode       = (id !== "")
        nameInput.text = name ?? ""
        imgSource      = img  ?? ""
        ipInput.text   = ip   ?? ""
        visible        = true
        nameInput.forceActiveFocus()
    }
    function close() { visible = false }

    // ── file picker ───────────────────────────────────────────────────────────
    FileDialog {
        id: imagePicker
        title: "Select Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.gif *.svg *.webp)", "All files (*)"]
        onAccepted: root.imgSource = selectedFile.toString()
    }

    MouseArea { anchors.fill: parent; onClicked: root.close() }

    // ── dialog box ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:  420
        height: formCol.implicitHeight + 48
        color:        Constant.bgDialog
        radius:       10
        border.color: Constant.border
        border.width: 1

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
            id: formCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
            spacing: 16

            // ── title ─────────────────────────────────────────────────────────
            Text {
                text:                root.editMode ? "Edit Equipment" : "Add Equipment"
                color:               Constant.textPrimary
                font.pixelSize:      18
                font.bold:           true
                Layout.fillWidth:    true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

            // ── name ──────────────────────────────────────────────────────────
            LabeledInput {
                id:               nameInput
                Layout.fillWidth: true
                label:            "Name *"
                placeholder:      "Enter equipment name"
                onReturnPressed:  ipInput.forceActiveFocus()
            }

            // ── IP ────────────────────────────────────────────────────────────
            LabeledInput {
                id:               ipInput
                Layout.fillWidth: true
                label:            "IP Address"
                placeholder:      "e.g. 192.168.0.101"
                inputHints:       Qt.ImhPreferNumbers
                onReturnPressed:  root.close()
            }

            // ── image ─────────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Image"; color: Constant.textHeader; font.pixelSize: 12 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 4
                        color: Constant.bgPanel
                        border.color: Constant.border
                        TextInput {
                            anchors { fill: parent; margins: 8 }
                            color: Constant.textPrimary
                            font.pixelSize: 14
                            text: root.imgSource
                            onTextEdited: root.imgSource = text
                        }
                        Text {
                            anchors { fill: parent; margins: 8 }
                            text: "File path or URL"
                            color: Constant.textSecondary
                            font.pixelSize: 14
                            visible: root.imgSource === ""
                        }
                    }

                    AppButton {
                        implicitWidth:  76
                        implicitHeight: 32
                        label:       "Browse"
                        bgColor:     Constant.btnBrowse.bg
                        hoverColor:  Constant.btnBrowse.bgHov
                        textColor:   Constant.btnBrowse.text
                        fontSize:    12
                        borderColor: Constant.btnBrowse.border
                        onClicked:   imagePicker.open()
                    }

                    AppButton {
                        implicitWidth:  56
                        implicitHeight: 32
                        visible:     root.editMode && root.imgSource !== ""
                        label:       "Remove"
                        bgColor:     Constant.danger.bg
                        hoverColor:  Constant.danger.bgHov
                        textColor:   Constant.danger.text
                        fontSize:    12
                        borderColor: Constant.danger.border
                        onClicked:   root.imgSource = ""
                    }
                }

                Rectangle {
                    implicitWidth:  64
                    implicitHeight: 64
                    radius: 4
                    color:        Constant.bgDetail
                    border.color: Constant.border
                    visible: root.imgSource !== ""
                    Image {
                        anchors { fill: parent; margins: 3 }
                        source:   root.imgSource
                        fillMode: Image.PreserveAspectFit
                        smooth:   true
                    }
                }
            }

            // ── footer ────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                AppButton {
                    implicitWidth:  90
                    implicitHeight: 36
                    label:       "Cancel"
                    fontSize:    13
                    bgColor:     Constant.cancelDlg.bg
                    hoverColor:  Constant.cancelDlg.bgHov
                    textColor:   Constant.textHeader
                    borderColor: Constant.cancelDlg.border
                    onClicked:   root.close()
                }

                AppButton {
                    implicitWidth:  120
                    implicitHeight: 36
                    label:       root.editMode ? "Save" : "Add Equipment"
                    fontSize:    13
                    bold:        true
                    enabled:     nameInput.text.trim() !== ""
                    bgColor:     nameInput.text.trim() === "" ? Constant.bgDetail      : Constant.confirmDlg.bg
                    hoverColor:  nameInput.text.trim() === "" ? Constant.bgDetail      : Constant.confirmDlg.bgHov
                    textColor:   nameInput.text.trim() === "" ? Constant.textSecondary : Constant.confirmDlg.text
                    borderColor: nameInput.text.trim() === "" ? Constant.textSecondary : Constant.confirmDlg.border
                    onClicked: {
                        var name = nameInput.text.trim()
                        if (name === "") return
                        root.confirmed(root.equipmentId, name, root.imgSource,
                                       ipInput.text.trim())
                        root.close()
                    }
                }
            }
        }
    }
}
