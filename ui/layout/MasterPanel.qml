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
    }
}
