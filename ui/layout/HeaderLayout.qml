import QtQuick
import "../components"

// Header — placeholder
Rectangle {
    implicitHeight: 56
    color:          Constant.bgPanel

    Text {
        anchors.centerIn: parent
        text:           "Top"
        color:          Constant.textPrimary
        font.pixelSize: 18
        font.bold:      true
    }
}
