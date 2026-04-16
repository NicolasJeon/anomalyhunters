import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

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
    color: "#a0000000"

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
        width:  400
        height: formCol.implicitHeight + 40
        color:        Constant.bgCard
        radius:       8
        border.color: Constant.border
        border.width: 1

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
            id: formCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
            spacing: 14

            Text {
                text:                root.editMode ? "Edit Equipment" : "Add Equipment"
                color:               "#c0c0e0"
                font.pixelSize:      16
                font.bold:           true
                Layout.fillWidth:    true
                horizontalAlignment: Text.AlignHCenter
            }

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
                spacing: 5

                Text { text: "Image"; color: "#7777aa"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 4
                        color: "#0e1020"
                        border.color: "#2a2c4e"
                        TextInput {
                            anchors { fill: parent; margins: 6 }
                            color: "#d0d0ee"
                            font.pixelSize: 11
                            text: root.imgSource
                            onTextEdited: root.imgSource = text
                        }
                        Text {
                            anchors { fill: parent; margins: 6 }
                            text: "File path or URL"
                            color: "#444466"
                            font.pixelSize: 11
                            visible: root.imgSource === ""
                        }
                    }

                    AppButton {
                        implicitWidth: 72
                        label:       "Browse"
                        bgColor:     "#181a2e"
                        hoverColor:  "#253050"
                        textColor:   "#88aaff"
                        fontSize:    11
                        borderColor: "#2a2c4e"
                        onClicked:   imagePicker.open()
                    }

                    AppButton {
                        implicitWidth: 44
                        visible:     root.editMode && root.imgSource !== ""
                        label:       "Remove"
                        bgColor:     "#1e1a1a"
                        hoverColor:  "#3a1a1a"
                        textColor:   "#cc6666"
                        fontSize:    11
                        borderColor: "#3a2a2a"
                        onClicked:   root.imgSource = ""
                    }
                }

                Rectangle {
                    implicitWidth:  64
                    implicitHeight: 64
                    radius: 4
                    color:        "#0e1020"
                    border.color: "#2a2c4e"
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
                spacing: 8
                Item { Layout.fillWidth: true }

                AppButton {
                    implicitWidth: 80
                    label:       "Cancel"
                    bgColor:     "#181828"
                    hoverColor:  "#2a1a2a"
                    textColor:   "#7777aa"
                    borderColor: "#3a3a5a"
                    onClicked:   root.close()
                }

                AppButton {
                    implicitWidth: 100
                    label:       root.editMode ? "Save" : "Add Equipment"
                    bgColor:     nameInput.text.trim() === "" ? "#141420" : "#1e1a40"
                    hoverColor:  nameInput.text.trim() === "" ? "#141420" : "#2a2560"
                    textColor:   nameInput.text.trim() === "" ? "#444466" : "#818cf8"
                    borderColor: nameInput.text.trim() === "" ? "#2a2c3e" : "#5558a0"
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
