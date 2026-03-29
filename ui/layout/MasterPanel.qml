import QtQuick
import QtQuick.Layouts
import "../components"

// 좌측 MASTER 패널 — 장비 목록 + 추가 버튼
Rectangle {
    id: root

    property var    devices:          []
    property string selectedDeviceId: ""

    signal deviceSelected(string id)
    signal startRequested(string id)
    signal stopRequested(string id)
    signal emergencyRequested(string id)
    signal resetRequested(string id)
    signal deleteRequested(string id)
    signal addRequested()
    signal startAllRequested()
    signal stopAllRequested()
    signal emergencyAllRequested()

    color: "#0e1020"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── 헤더 ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 46
            color: "#181a2e"

            RowLayout {
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 12 }
                spacing: 8

                Text {
                    text: "Devices"
                    color: "#c0c0e0"; font.pixelSize: 15; font.bold: true
                }

                Rectangle {
                    implicitWidth: 26; implicitHeight: 22; radius: 4
                    color: addMouse.containsMouse ? "#2a4a2a" : "#1a3a1a"
                    Text { anchors.centerIn: parent; text: "+"; color: "#66dd66"; font.pixelSize: 16; font.bold: true }
                    MouseArea {
                        id: addMouse
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root.addRequested()
                    }
                }
            }
        }

        // ── 디바이스 목록 ──────────────────────────────────────────────────
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.devices

            delegate: DeviceListItem {
                required property var modelData
                width: ListView.view.width
                deviceData: modelData
                isSelected: modelData["id"] === root.selectedDeviceId
                onSelected:           root.deviceSelected(modelData["id"])
                onStartRequested:     root.startRequested(modelData["id"])
                onStopRequested:      root.stopRequested(modelData["id"])
                onEmergencyRequested: root.emergencyRequested(modelData["id"])
                onResetRequested:     root.resetRequested(modelData["id"])
                onDeleteRequested:    root.deleteRequested(modelData["id"])
            }
        }

        // ── 하단 전체 제어 버튼 ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            color: "#0e1020"

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#2a2c4e"
            }

            Row {
                anchors { fill: parent; margins: 6 }
                spacing: 6

                // All Start
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: parent.height
                    radius: 4
                    color: allStartMouse.containsMouse ? "#1a4a1a" : "#122012"
                    border.color: allStartMouse.containsMouse ? "#44bb44" : "#2a5a2a"
                    Text {
                        anchors.centerIn: parent
                        text: "▶ All"
                        color: "#66dd66"; font.pixelSize: 12; font.bold: true
                    }
                    MouseArea {
                        id: allStartMouse
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root.startAllRequested()
                    }
                }

                // All Stop
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: parent.height
                    radius: 4
                    color: "#4a1a1a"
                    Text {
                        anchors.centerIn: parent
                        text: "⏹ All"
                        color: "#ff6666"; font.pixelSize: 12; font.bold: true
                    }
                    MouseArea {
                        id: allStopMouse
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root.stopAllRequested()
                    }
                }

                // All E-Stop
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: parent.height
                    radius: 4
                    color: allEstopMouse.containsMouse ? "#3a1a00" : "#101010"
                    border.color: allEstopMouse.containsMouse ? "#ff6600" : "#3a3a4a"
                    Text {
                        anchors.centerIn: parent
                        text: "E-Stop All"
                        color: allEstopMouse.containsMouse ? "#ff8833" : "#888899"
                        font.pixelSize: 12; font.bold: true
                    }
                    MouseArea {
                        id: allEstopMouse
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root.emergencyAllRequested()
                    }
                }
            }
        }
    }
}
