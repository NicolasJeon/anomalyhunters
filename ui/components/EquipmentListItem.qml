import QtQuick
import QtQuick.Layouts
import QtFacility

// Equipment list item
Rectangle {
    id: root

    property var  equipmentData: ({})
    property bool isSelected:    false

    signal selected()
    signal startRequested()
    signal stopRequested()
    signal deleteRequested()

    readonly property string controlStatus: equipmentData["controlStatus"] ?? "Stopped"
    readonly property string healthStatus:  equipmentData["healthStatus"]  ?? "N/A"
    readonly property string ip:            equipmentData["ip"]            ?? ""
    readonly property bool   isRunning:     controlStatus === "Running"

    height: 72
    color:  root.isSelected ? Constant.selectionBg : Constant.bgPanel

    // ── selection bar ─────────────────────────────────────────────────────────
    Rectangle {
        width:  3
        height: parent.height
        color:  root.isSelected ? Constant.focusAccent : "transparent"
    }

    // ── divider ───────────────────────────────────────────────────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        width:  parent.width
        height: 1
        color:  "#1e2035"
    }

    MouseArea { anchors.fill: parent; onClicked: root.selected() }

    RowLayout {
        anchors {
            fill:         parent
            leftMargin:   12
            rightMargin:  10
            topMargin:     8
            bottomMargin:  8
        }
        spacing: 10

        // ── thumbnail ─────────────────────────────────────────────────────────
        Item {
            implicitWidth:  38
            implicitHeight: 38
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: 6
                color:  root.isRunning ? "#12182e" : "#0c0e18"

                Image {
                    anchors { fill: parent; margins: 3 }
                    source: (root.equipmentData["imageSource"] ?? "") !== ""
                            ? root.equipmentData["imageSource"]
                            : "qrc:/images/default.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true
                    opacity:  root.isRunning ? 1.0 : 0.35
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // ── status dot ────────────────────────────────────────────────
                Rectangle {
                    anchors { right: parent.right; bottom: parent.bottom }
                    width:  8; height: 8; radius: 4
                    color:        root.isRunning
                                  ? Constant.healthColor(root.healthStatus)
                                  : Constant.stopped
                    border.color: "#0c0e18"
                    border.width: 1
                }
            }
        }

        // ── name + IP ─────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth:  true
            Layout.alignment:  Qt.AlignVCenter
            spacing: 3

            Text {
                text:           root.equipmentData["name"] ?? ""
                color:          root.isRunning ? "#d0d0ee" : "#555570"
                font.pixelSize: 13
                font.bold:      true
                elide:          Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text:           root.ip !== "" ? root.ip : "—"
                color:          root.isRunning ? "#55557a" : "#333350"
                font.pixelSize: 11
                font.bold:      true
                elide:          Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        // ── toggle ────────────────────────────────────────────────────────────
        ControlSwitch {
            Layout.alignment: Qt.AlignVCenter
            isRunning:        root.isRunning
            onStartRequested: root.startRequested()
            onStopRequested:  root.stopRequested()
        }

        // ── delete ────────────────────────────────────────────────────────────
        Rectangle {
            implicitWidth:  26
            implicitHeight: 26
            radius:         4
            color:          deleteArea.containsMouse ? "#3a1010" : "transparent"
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text:           "✕"
                color:          deleteArea.containsMouse ? "#cc5555" : "#4a3040"
                font.pixelSize: 12
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id:           deleteArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked:    root.deleteRequested()
            }
        }
    }
}
