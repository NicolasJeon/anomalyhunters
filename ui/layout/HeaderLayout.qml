import QtQuick
import "../components"

// App header — logo / clock / test mode
Rectangle {
    id: root

    property alias testModeBtn: testModeBtn

    implicitHeight: 56
    color: Constant.bgDialog

    Image {
        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
        source:   "qrc:/images/logo.svg"
        height:   36
        fillMode: Image.PreserveAspectFit
    }

    Text {
        anchors.centerIn: parent
        text:             Qt.formatDateTime(new Date(), "yyyy-MM-dd  hh:mm:ss")
        color:            Constant.textHeader
        font.pixelSize:   15
        font.family:      "Courier New"

        Timer {
            interval: 1000
            running:  true
            repeat:   true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd  hh:mm:ss")
        }
    }

    AppButton {
        id: testModeBtn
        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
        implicitWidth: 130
        label:       "Test Mode"
        bgColor:     Constant.bgDialog
        hoverColor:  Constant.bgDialog
        textColor:   Constant.primary.bg
        borderColor: Constant.primary.bg
        fontSize:    14
        bold:        true
    }
}
