import QtQuick
import QtQuick.Layouts
import QtFacility

// Equipment image card with placeholder
Rectangle {
    id: root

    property string imageSource: ""

    radius: 8
    color: Constant.bgDetail
    border.color: Constant.border
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
