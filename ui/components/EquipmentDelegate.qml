import QtQuick
import QtQuick.Layouts

// qmllint disable unqualified
Rectangle {
    id: root
    height: 64

    property string equipmentId: model.id
    property bool   isSelected:  false

    signal selected()
    signal deleteRequested(string equipmentId)

    color: root.isSelected ? Constant.selectionBg : Constant.bgPanel
    Behavior on color { ColorAnimation { duration: 150 } }

    // ── selection bar ─────────────────────────────────────────────────────────
    Rectangle {
        width:  3
        height: parent.height
        color:  root.isSelected ? Constant.focusAccent : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked:    root.selected()
    }

    RowLayout {
        anchors.fill:    parent
        anchors.margins: 12
        spacing:         10

        // ── thumbnail ─────────────────────────────────────────────────────────
        Rectangle {
            width: 38; height: 38; radius: 6
            color: model.running ? Constant.bgThumb : Constant.bgThumbOff

            Image {
                anchors { fill: parent; margins: 4 }
                source:   model.imageSource !== "" ? model.imageSource
                                                   : "qrc:/images/default.png"
                fillMode: Image.PreserveAspectFit
                smooth:   true
                opacity:  model.running ? 1.0 : 0.35
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text:             model.name
                color:            Constant.textPrimary
                font.pixelSize:   13
                font.bold:        true
                elide:            Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text:           model.ip
                color:          Constant.textSecondary
                font.pixelSize: 11
            }
        }

        ControlSwitch {
            isRunning: model.running
        }

        // ── delete button ─────────────────────────────────────────────────────
        Rectangle {
            implicitWidth:  26
            implicitHeight: 26
            radius:         4
            color:          deleteArea.containsMouse ? "#3a1010" : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text:           "✕"
                color:          deleteArea.containsMouse ? "#cc5555" : Constant.textMuted
                font.pixelSize: 12
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id:           deleteArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: root.deleteRequested(root.equipmentId)
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width:  parent.width
        height: 1
        color:  Constant.divider
    }
}
