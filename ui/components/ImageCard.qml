import QtQuick
import QtQuick.Layouts

// Equipment image card with placeholder
Rectangle {
    id: root

    property string imageSource: ""

    radius: 8
    color: "#0e1020"
    border.color: "#2a2c4e"
    border.width: 1

    Image {
        readonly property bool isDefault: root.imageSource === ""
        anchors {
            fill:    parent
            margins: isDefault ? 0 : 8
        }
        source:   isDefault ? "qrc:/images/default.png"
                            : root.imageSource
        fillMode: isDefault ? Image.Pad : Image.PreserveAspectFit
        smooth:   true
        mipmap:   true
    }
}
