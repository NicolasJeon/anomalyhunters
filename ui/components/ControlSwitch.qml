import QtQuick
import QtQuick.Controls
import QtFacility

// Start/Stop toggle switch
Switch {
    id: root

    property bool isRunning: false

    signal startRequested()
    signal stopRequested()

    implicitWidth:  42
    implicitHeight: 24
    padding: 0; spacing: 0
    contentItem: null; background: null

    Binding on checked { value: root.isRunning }
    onClicked: root.isRunning ? root.stopRequested() : root.startRequested()

    indicator: Rectangle {
        implicitWidth:  42
        implicitHeight: 24
        radius: height / 2
        color:  root.checked ? Constant.inputFocusBorder : Constant.switchOffBg
        scale:  root.pressed ? 0.88 : 1.0
        border.color: root.checked ? "transparent" : Constant.switchOffBorder
        border.width: 1

        Behavior on color        { ColorAnimation  { duration: 200 } }
        Behavior on border.color { ColorAnimation  { duration: 200 } }
        Behavior on scale        { NumberAnimation { duration: 80  } }

        Rectangle {
            width:  16; height: 16; radius: 8
            anchors.verticalCenter: parent.verticalCenter
            x:     root.checked ? parent.width - 19 : 3
            color: root.checked ? Constant.white : Constant.switchKnobOff

            Behavior on x     { NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 0.4 } }
            Behavior on color { ColorAnimation  { duration: 200 } }
        }
    }
}
