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
        color:            "#c0c0e0"
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
        bgColor:     "#111a11"
        hoverColor:  "#1a2a1a"
        textColor:   "#55bb77"
        borderColor: "#336644"
        fontSize:    14
        bold:        true
    }
}
