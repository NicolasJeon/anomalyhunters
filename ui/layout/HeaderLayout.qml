import QtQuick
import "../components"

// Header — placeholder
Rectangle {
    implicitHeight: 56
    color:          Constant.bgCard

    Text {
        anchors.centerIn: parent
        text:           "AnomalyHunters"
        color:          Constant.textPrimary
        font.pixelSize: 18
        font.bold:      true
    }
}
