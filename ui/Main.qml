import QtQuick
import "layout"
import "components"

Window {
    width:         1280
    height:        720
    minimumWidth:  1280
    minimumHeight: 720
    visible: true
    title:   "Equipment Monitor"
    color:   Constant.bgWindow

    AppLayout {
        anchors.fill: parent
    }
}
