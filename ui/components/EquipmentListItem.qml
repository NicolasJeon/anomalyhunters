import QtQuick
import QtQuick.Layouts
import QtFacility

// 장비 목록 아이템 — 썸네일 / 이름·상태 / 상태별 제어 버튼
// controlStatus: "Stopped" | "Running"
Rectangle {
    id: root

    property var  equipmentData: ({})
    property bool isSelected:    false

    signal selected()
    signal startRequested()
    signal stopRequested()
    signal deleteRequested()

    // ── 편의 속성 (반복 참조 단축) ─────────────────────────────────────────
    readonly property string controlStatus: equipmentData["controlStatus"] ?? "Stopped"
    readonly property string healthStatus:  equipmentData["healthStatus"]  ?? "Normal"

    // healthStatus → 표시 색상 (Constant.healthColor 위임)
    function healthColor(status) { return Constant.healthColor(status) }

    // ── 인라인 컴포넌트: 삭제(−) 버튼 (세 상태 공통) ───────────────────────
    component DeleteBtn: AppButton {
        implicitWidth: 22
        implicitHeight: 18
        label: "−"
        bold: true
        fontSize: 14
        bgColor:     Constant.ctrlDeleteBg
        hoverColor:  Constant.ctrlDeleteBgHov
        textColor:   Constant.ctrlDeleteText
        borderColor: Constant.ctrlDeleteBorder
        onClicked: root.deleteRequested()
    }

    height: 76
    color: root.isSelected ? Constant.selectionBg : Constant.bgPanel

    // 선택 표시 바
    Rectangle { width: 3; height: parent.height; color: root.isSelected ? Constant.focusAccent : "transparent" }

    // 하단 구분선
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#1e2035"
    }

    MouseArea { anchors.fill: parent; onClicked: root.selected() }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 8
            topMargin: 6
            bottomMargin: 6
        }
        spacing: 8

        // ── 썸네일 ────────────────────────────────────────────────────────
        Item {
            implicitWidth: 36
            implicitHeight: 36
            Layout.alignment: Qt.AlignVCenter

            // 이미지 없을 때: 상태 도트
            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: 5
                color: root.healthColor(root.healthStatus)
                visible: false
            }

            // 이미지 있을 때: 이미지 + 우하단 상태 도트
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: "#0e1020"
                visible: true

                Image {
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    source: (root.equipmentData["imageSource"] ?? "") !== ""
                            ? root.equipmentData["imageSource"]
                            : "qrc:/qt/qml/QtFacility/images/default.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    width: 8
                    height: 8
                    radius: 4
                    color: root.healthColor(root.healthStatus)
                    border.color: "#0e1020"
                    border.width: 1
                }
            }
        }

        // ── 이름 / 상태 / 제어 버튼 ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                text: root.equipmentData["name"] ?? ""
                color: "#d0d0ee"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.healthStatus
                color: "#666688"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Stopped → [Start] ··· [−]
            RowLayout {
                Layout.fillWidth: true
                visible: root.controlStatus === "Stopped"
                spacing: 4
                AppButton {
                    implicitWidth: 44
                    implicitHeight: 18
                    label: "Start"
                    fontSize: 10
                    bgColor:    Constant.ctrlStartBg
                    hoverColor: Constant.ctrlStartBgHov
                    textColor:  Constant.ctrlStartText
                    onClicked: root.startRequested()
                }
                Item { Layout.fillWidth: true }
                DeleteBtn {}
            }

            // Running → [Stop] ··· [−]
            RowLayout {
                Layout.fillWidth: true
                visible: root.controlStatus === "Running"
                spacing: 4
                AppButton {
                    implicitWidth: 44
                    implicitHeight: 18
                    label: "Stop"
                    fontSize: 10
                    bgColor:    Constant.ctrlStopBg
                    hoverColor: Constant.ctrlStopBgHov
                    textColor:  Constant.ctrlStopText
                    onClicked: root.stopRequested()
                }
                Item { Layout.fillWidth: true }
                DeleteBtn {}
            }
        }
    }
}
