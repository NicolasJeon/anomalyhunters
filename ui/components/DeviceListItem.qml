import QtQuick
import QtQuick.Layouts

// 디바이스 목록 아이템 — 썸네일 / 이름·타입 / 상태 버튼 (텍스트 하단)
// controlStatus: "stopped" | "running" | "emergency"
Rectangle {
    id: root

    property var  deviceData: ({})
    property bool isSelected: false

    signal selected()
    signal startRequested()
    signal stopRequested()
    signal emergencyRequested()
    signal resetRequested()
    signal deleteRequested()

    height: 76
    color: root.isSelected ? "#1e2a46" : "#0e1020"

    function healthColor(status) {
        if (status === "emergency") return "#ff4400"
        if (status === "anomaly")   return "#cc3344"
        if (status === "warning")   return "#e8a030"
        if (status === "normal")    return "#22aa66"
        return "#555577"
    }

    // 선택 표시 바
    Rectangle {
        width: 3; height: parent.height
        color: root.isSelected ? "#5599ff" : "transparent"
    }

    // 구분선
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: "#1e2035"
    }

    MouseArea { anchors.fill: parent; onClicked: root.selected() }

    // ── 메인 콘텐츠 ───────────────────────────────────────────────────────
    RowLayout {
        anchors { fill: parent; leftMargin: 12; rightMargin: 8; topMargin: 6; bottomMargin: 6 }
        spacing: 8

        // 썸네일
        Item {
            implicitWidth: 36; implicitHeight: 36
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.centerIn: parent
                width: 10; height: 10; radius: 5
                color: root.healthColor(root.deviceData["healthStatus"] ?? "")
                visible: (root.deviceData["imageSource"] ?? "") === ""
            }

            Rectangle {
                anchors.fill: parent; radius: 4; color: "#0e1020"
                visible: (root.deviceData["imageSource"] ?? "") !== ""
                Image {
                    anchors { fill: parent; margins: 2 }
                    source: root.deviceData["imageSource"] ?? ""
                    fillMode: Image.PreserveAspectFit; smooth: true
                }
                Rectangle {
                    anchors { right: parent.right; bottom: parent.bottom }
                    width: 8; height: 8; radius: 4
                    color: root.healthColor(root.deviceData["healthStatus"] ?? "")
                    border.color: "#0e1020"; border.width: 1
                }
            }
        }

        // 이름 / 타입 / 버튼
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                text: root.deviceData["name"] ?? ""
                color: "#d0d0ee"; font.pixelSize: 13; font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: (root.deviceData["type"] ?? "") + "  ·  "
                      + (root.deviceData["healthStatus"] ?? "")
                color: root.deviceData["healthStatus"] === "emergency" ? "#ff6622" : "#666688"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // ── stopped: [▶ Start]  ···  [−] ─────────────────────────
            RowLayout {
                Layout.fillWidth: true
                visible: root.deviceData["controlStatus"] === "stopped"
                spacing: 4

                Rectangle {
                    implicitWidth: 44; implicitHeight: 18; radius: 3
                    color: "#1a3a1a"
                    Text { anchors.centerIn: parent; text: "Start"; color: "#66dd66"; font.pixelSize: 10 }
                    MouseArea { anchors.fill: parent; onClicked: root.startRequested() }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    implicitWidth: 22; implicitHeight: 18; radius: 3
                    color: del1.containsMouse ? "#3a1a1a" : "#1e1e2e"
                    border.color: del1.containsMouse ? "#aa4444" : "#2a2a3e"; border.width: 1
                    Text { anchors.centerIn: parent; text: "−"; color: "#aa4444"; font.pixelSize: 14; font.bold: true }
                    MouseArea { id: del1; anchors.fill: parent; hoverEnabled: true; onClicked: root.deleteRequested() }
                }
            }

            // ── running: [⏹ Stop][⚠]  ···  [−] ──────────────────────
            RowLayout {
                Layout.fillWidth: true
                visible: root.deviceData["controlStatus"] === "running"
                spacing: 4

                Rectangle {
                    implicitWidth: 44; implicitHeight: 18; radius: 3
                    color: "#4a1a1a"
                    Text { anchors.centerIn: parent; text: "Stop"; color: "#ff6666"; font.pixelSize: 10 }
                    MouseArea { anchors.fill: parent; onClicked: root.stopRequested() }
                }
                Rectangle {
                    implicitWidth: 44; implicitHeight: 18; radius: 3
                    color: emgM.containsMouse ? "#5a2000" : "#1a1a1a"
                    border.color: emgM.containsMouse ? "#ff6600" : "#3a3a4a"; border.width: 1
                    Text { anchors.centerIn: parent; text: "E-Stop"; color: emgM.containsMouse ? "#ff9944" : "#888899"; font.pixelSize: 10 }
                    MouseArea { id: emgM; anchors.fill: parent; hoverEnabled: true; onClicked: root.emergencyRequested() }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    implicitWidth: 22; implicitHeight: 18; radius: 3
                    color: del2.containsMouse ? "#3a1a1a" : "#1e1e2e"
                    border.color: del2.containsMouse ? "#aa4444" : "#2a2a3e"; border.width: 1
                    Text { anchors.centerIn: parent; text: "−"; color: "#aa4444"; font.pixelSize: 14; font.bold: true }
                    MouseArea { id: del2; anchors.fill: parent; hoverEnabled: true; onClicked: root.deleteRequested() }
                }
            }

            // ── emergency: [↺ Reset]  ···  [−] ───────────────────────
            RowLayout {
                Layout.fillWidth: true
                visible: root.deviceData["controlStatus"] === "emergency"
                spacing: 4

                Rectangle {
                    implicitWidth: 60; implicitHeight: 18; radius: 3
                    color: rstM.containsMouse ? "#2a2a6a" : "#1a1a4a"
                    border.color: "#5555cc"; border.width: 1
                    Text { anchors.centerIn: parent; text: "↺ Reset"; color: "#aaaaff"; font.pixelSize: 10 }
                    MouseArea { id: rstM; anchors.fill: parent; hoverEnabled: true; onClicked: root.resetRequested() }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    implicitWidth: 22; implicitHeight: 18; radius: 3
                    color: del3.containsMouse ? "#3a1a1a" : "#1e1e2e"
                    border.color: del3.containsMouse ? "#aa4444" : "#2a2a3e"; border.width: 1
                    Text { anchors.centerIn: parent; text: "−"; color: "#aa4444"; font.pixelSize: 14; font.bold: true }
                    MouseArea { id: del3; anchors.fill: parent; hoverEnabled: true; onClicked: root.deleteRequested() }
                }
            }
        }
    }
}
