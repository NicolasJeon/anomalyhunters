import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

// 장비 추가 / 수정 공용 다이얼로그
//
// 사용법)
//   DeviceDialog { id: dlg; onConfirmed: (id, name, img) => { ... } }
//
//   dlg.open("", "", "")       // 추가 모드
//   dlg.open(id, name, imgSrc) // 수정 모드 (id가 비어 있지 않으면 수정)
//
// confirmed 시그널)
//   id가 ""이면 추가, 아니면 수정으로 처리
Rectangle {
    id: root

    property bool   editMode: false  // 수정 모드 여부 (open() 이 자동 설정)
    property string deviceId: ""     // 수정 대상 장비 ID
    property string imgSource: ""    // 선택된 이미지 경로

    signal confirmed(string deviceId, string name, string imgSource)

    visible: false
    color: "#a0000000"   // 반투명 어두운 오버레이

    // ── 열기 / 닫기 ──────────────────────────────────────────────────────
    function open(id, name, img) {
        deviceId       = id
        editMode       = (id !== "")
        nameInput.text = name ?? ""
        imgSource      = img  ?? ""
        visible        = true
        nameInput.forceActiveFocus()
    }
    function close() { visible = false }

    // ── 이미지 파일 선택 다이얼로그 ──────────────────────────────────────
    FileDialog {
        id: imagePicker
        title: "Select Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.gif *.svg *.webp)", "All files (*)"]
        onAccepted: root.imgSource = selectedFile.toString()
    }

    // 오버레이 클릭 시 닫기
    MouseArea { anchors.fill: parent; onClicked: root.close() }

    // ── 다이얼로그 박스 ──────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: formCol.implicitHeight + 40
        color: "#1a1c2e"
        radius: 8
        border.color: "#2a2c4e"
        border.width: 1

        MouseArea { anchors.fill: parent; onClicked: {} }   // 이벤트 전파 차단

        ColumnLayout {
            id: formCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 20
            }
            spacing: 16

            // 제목
            Text {
                text: root.editMode ? "Edit Device" : "Add Device"
                color: "#c0c0e0"
                font.pixelSize: 16
                font.bold: true
            }

            // ── 이름 입력 ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text { text: "Name *"; color: "#7777aa"; font.pixelSize: 11 }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 4
                    color: "#0e1020"
                    border.color: nameInput.activeFocus ? "#5599ff" : "#2a2c4e"

                    TextInput {
                        id: nameInput
                        anchors {
                            fill: parent
                            margins: 8
                        }
                        color: "#d0d0ee"
                        font.pixelSize: 13
                        Keys.onReturnPressed: root.close()
                    }
                    // 플레이스홀더
                    Text {
                        anchors {
                            fill: parent
                            margins: 8
                        }
                        text: "Enter device name"
                        color: "#444466"
                        font.pixelSize: 13
                        visible: nameInput.text === ""
                    }
                }
            }

            // ── 이미지 선택 ───────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text { text: "Image"; color: "#7777aa"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // 경로 직접 입력
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 4
                        color: "#0e1020"
                        border.color: "#2a2c4e"
                        TextInput {
                            anchors {
                                fill: parent
                                margins: 6
                            }
                            color: "#d0d0ee"
                            font.pixelSize: 11
                            text: root.imgSource
                            onTextEdited: root.imgSource = text
                        }
                        Text {
                            anchors {
                                fill: parent
                                margins: 6
                            }
                            text: "File path or URL"
                            color: "#444466"
                            font.pixelSize: 11
                            visible: root.imgSource === ""
                        }
                    }

                    AppButton {
                        implicitWidth: 72
                        label: "Browse"
                        bgColor: "#181a2e"
                        hoverColor: "#253050"
                        textColor: "#88aaff"
                        fontSize: 11
                        borderColor: "#2a2c4e"
                        onClicked: imagePicker.open()
                    }

                    // 수정 모드에서만 이미지 제거 버튼 표시
                    AppButton {
                        implicitWidth: 44
                        visible: root.editMode && root.imgSource !== ""
                        label: "Remove"
                        bgColor: "#1e1a1a"
                        hoverColor: "#3a1a1a"
                        textColor: "#cc6666"
                        fontSize: 11
                        borderColor: "#3a2a2a"
                        onClicked: root.imgSource = ""
                    }
                }

                // 이미지 미리보기
                Rectangle {
                    implicitWidth: 64
                    implicitHeight: 64
                    radius: 4
                    color: "#0e1020"
                    border.color: "#2a2c4e"
                    visible: root.imgSource !== ""
                    Image {
                        anchors {
                            fill: parent
                            margins: 3
                        }
                        source: root.imgSource
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }
            }

            // ── 하단 버튼 행 ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Item { Layout.fillWidth: true }

                AppButton {
                    implicitWidth: 80
                    label: "Cancel"
                    bgColor: "#181828"
                    hoverColor: "#2a1a2a"
                    textColor: "#7777aa"
                    borderColor: "#3a3a5a"
                    onClicked: root.close()
                }

                // 이름이 비어 있으면 비활성 스타일
                AppButton {
                    implicitWidth: 100
                    label: root.editMode ? "Save" : "Add Device"
                    bgColor:      nameInput.text.trim() === "" ? "#141420" : "#143820"
                    hoverColor:   nameInput.text.trim() === "" ? "#141420" : "#1a5a2a"
                    textColor:    nameInput.text.trim() === "" ? "#444466" : "#66dd66"
                    borderColor:  nameInput.text.trim() === "" ? "#2a2c3e" : "#2a6a3a"
                    onClicked: {
                        var name = nameInput.text.trim()
                        if (name === "") return
                        root.confirmed(root.deviceId, name, root.imgSource)
                        root.close()
                    }
                }
            }
        }
    }
}
