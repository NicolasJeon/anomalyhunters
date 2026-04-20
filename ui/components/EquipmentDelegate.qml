import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    height: 64
    color:  Constant.bgPanel

    RowLayout {
        anchors.fill:    parent
        anchors.margins: 12
        spacing:         10

        Rectangle {
            width: 36; height: 36; radius: 4
            color: Constant.bgThumb

            Text {
                anchors.centerIn: parent
                text:           "⚙"
                font.pixelSize: 20
                color:          Constant.textSecondary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                id:             nameText
                text:           model.name
                color:          Constant.textPrimary
                font.pixelSize: 13
                font.bold:      true
            }

            Text {
                id:             ipText
                text:           model.ip
                color:          Constant.textSecondary
                font.pixelSize: 11
            }
        }

        ControlSwitch {
            isRunning: model.running
        }

        Text {
            text:           "✕"
            color:          Constant.textMuted
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    {} // step4에서 구현
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
