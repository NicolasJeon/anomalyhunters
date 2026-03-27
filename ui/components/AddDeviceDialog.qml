import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

// 장비 추가 모달 다이얼로그 — anchors.fill: parent + z: 100 으로 사용
Rectangle {
    id: root

    property string imageSource: ""

    signal deviceAdded(string name, string type, string imageSource)

    visible: false
    color: "#a0000000"

    function open() {
        nameInput.text = ""
        typeInput.text = "Generic"
        imageSource    = ""
        visible        = true
        nameInput.forceActiveFocus()
    }
    function close() { visible = false }

    // ── 이미지 선택 파일 다이얼로그 ──────────────────────────────────────
    FileDialog {
        id: imagePicker
        title: "이미지 선택"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.gif *.svg *.webp)", "All files (*)"]
        onAccepted: root.imageSource = selectedFile.toString()
    }

    MouseArea { anchors.fill: parent; onClicked: root.close() }

    // ── 다이얼로그 박스 ───────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: dialogCol.implicitHeight + 40
        color: "#1a1c2e"; radius: 8
        border.color: "#2a2c4e"; border.width: 1

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
            id: dialogCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
            spacing: 16

            Text { text: "장비 추가"; color: "#c0c0e0"; font.pixelSize: 16; font.bold: true }

            // ── 이름 ─────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text { text: "이름 *"; color: "#7777aa"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 32; radius: 4
                    color: "#0e1020"
                    border.color: nameInput.activeFocus ? "#5599ff" : "#2a2c4e"
                    TextInput {
                        id: nameInput
                        anchors { fill: parent; margins: 8 }
                        color: "#d0d0ee"; font.pixelSize: 13
                        Keys.onReturnPressed: typeInput.forceActiveFocus()
                    }
                    Text {
                        anchors { fill: parent; margins: 8 }
                        text: "장비 이름 입력"; color: "#444466"; font.pixelSize: 13
                        visible: nameInput.text === ""
                    }
                }
            }

            // ── 타입 ─────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text { text: "타입"; color: "#7777aa"; font.pixelSize: 11 }

                RowLayout {
                    spacing: 4
                    Repeater {
                        model: ["Compressor", "Pump", "Motor", "Generic"]
                        delegate: Rectangle {
                            required property var modelData
                            implicitWidth: 80; implicitHeight: 24; radius: 3
                            color: typeInput.text === modelData ? "#253050" : "#181a2e"
                            border.color: typeInput.text === modelData ? "#5599ff" : "#2a2c4e"
                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: typeInput.text === parent.modelData ? "#88aaff" : "#7777aa"
                                font.pixelSize: 10
                            }
                            MouseArea { anchors.fill: parent; onClicked: typeInput.text = parent.modelData }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 28; radius: 4
                    color: "#0e1020"
                    border.color: typeInput.activeFocus ? "#5599ff" : "#2a2c4e"
                    TextInput {
                        id: typeInput
                        anchors { fill: parent; margins: 6 }
                        color: "#d0d0ee"; font.pixelSize: 12
                    }
                    Text {
                        anchors { fill: parent; margins: 6 }
                        text: "직접 입력..."; color: "#444466"; font.pixelSize: 12
                        visible: typeInput.text === ""
                    }
                }
            }

            // ── 이미지 ───────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text { text: "이미지"; color: "#7777aa"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: 28; radius: 4
                        color: "#0e1020"; border.color: "#2a2c4e"
                        TextInput {
                            id: imagePathInput
                            anchors { fill: parent; margins: 6 }
                            color: "#d0d0ee"; font.pixelSize: 11
                            text: root.imageSource
                            onTextEdited: root.imageSource = text
                        }
                        Text {
                            anchors { fill: parent; margins: 6 }
                            text: "파일 경로 또는 URL"; color: "#444466"; font.pixelSize: 11
                            visible: root.imageSource === ""
                        }
                    }

                    Rectangle {
                        implicitWidth: 72; implicitHeight: 28; radius: 4
                        color: browseMouse.containsMouse ? "#253050" : "#181a2e"
                        border.color: "#2a2c4e"
                        Text { anchors.centerIn: parent; text: "찾아보기"; color: "#88aaff"; font.pixelSize: 11 }
                        MouseArea {
                            id: browseMouse
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: imagePicker.open()
                        }
                    }
                }

                // 미리보기
                Rectangle {
                    implicitWidth: 64; implicitHeight: 64; radius: 4
                    color: "#0e1020"; border.color: "#2a2c4e"
                    visible: root.imageSource !== ""
                    Image {
                        anchors { fill: parent; margins: 3 }
                        source: root.imageSource
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                }
            }

            // ── 버튼 ─────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 80; implicitHeight: 30; radius: 4
                    color: cancelMouse.containsMouse ? "#2a1a2a" : "#181828"
                    border.color: "#3a3a5a"
                    Text { anchors.centerIn: parent; text: "취소"; color: "#7777aa"; font.pixelSize: 12 }
                    MouseArea { id: cancelMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.close() }
                }

                Rectangle {
                    implicitWidth: 100; implicitHeight: 30; radius: 4
                    color: {
                        if (nameInput.text.trim() === "") return "#141420"
                        return confirmMouse.containsMouse ? "#1a5a2a" : "#143820"
                    }
                    border.color: nameInput.text.trim() === "" ? "#2a2c3e" : "#2a6a3a"
                    Text {
                        anchors.centerIn: parent; text: "장비 추가"; font.pixelSize: 12
                        color: nameInput.text.trim() === "" ? "#444466" : "#66dd66"
                    }
                    MouseArea {
                        id: confirmMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            var name = nameInput.text.trim()
                            if (name === "") return
                            root.deviceAdded(name, typeInput.text.trim() || "Generic", root.imageSource)
                            root.close()
                        }
                    }
                }
            }
        }
    }
}
