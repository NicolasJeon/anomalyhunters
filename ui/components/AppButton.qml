import QtQuick
import QtFacility

// Reusable button
Rectangle {
    id: root

    property string label:            ""
    property color  bgColor:          Constant.btnDefault.bg
    property color  hoverColor:       bgColor
    property color  textColor:        Constant.btnDefault.text
    property color  hoverTextColor:   textColor
    property color  borderColor:      "transparent"
    property color  hoverBorderColor: borderColor
    property int    fontSize:         12
    property bool   bold:             false

    signal clicked()

    implicitHeight: 30
    radius: 4
    color:        mouse.containsMouse ? root.hoverColor       : root.bgColor
    border.color: mouse.containsMouse ? root.hoverBorderColor : root.borderColor
    border.width: 1
    opacity: root.enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text:           root.label
        color:          mouse.containsMouse ? root.hoverTextColor : root.textColor
        font.pixelSize: root.fontSize
        font.bold:      root.bold
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked:    root.clicked()
    }
}
