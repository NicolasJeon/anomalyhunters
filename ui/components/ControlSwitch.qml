import QtQuick
import QtFacility

// Start/Stop toggle switch
Rectangle {
    id: root

    property bool isRunning: false

    signal startRequested()
    signal stopRequested()

    implicitWidth:  42
    implicitHeight: 24
    radius: height / 2
    color:  root.isRunning ? Constant.inputFocusBorder : Constant.switchOffBg
    scale:  tapHandler.pressed ? 0.88 : 1.0
    border.color: root.isRunning ? "transparent" : Constant.switchOffBorder
    border.width: 1

    Behavior on color        { ColorAnimation  { duration: 200 } }
    Behavior on border.color { ColorAnimation  { duration: 200 } }
    Behavior on scale        { NumberAnimation { duration: 80  } }

    Rectangle {
        width:  16; height: 16; radius: 8
        anchors.verticalCenter: parent.verticalCenter
        x:     root.isRunning ? parent.width - 19 : 3
        color: root.isRunning ? Constant.white : Constant.switchKnobOff

        Behavior on x     { NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 0.4 } }
        Behavior on color { ColorAnimation  { duration: 200 } }
    }

    TapHandler {
        id: tapHandler
        onTapped: root.isRunning ? root.stopRequested() : root.startRequested()
    }
}
