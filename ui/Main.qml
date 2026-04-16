import QtQuick
import "layout"
import "components"

// equipmentManager injected via setContextProperty() in main.cpp
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
