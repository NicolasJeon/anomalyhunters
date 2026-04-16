import QtQuick
import QtQuick.Layouts
import QtFacility

// Sensor row: gauge bar + icon + label + value
RowLayout {
    id: root

    property string iconSource: ""
    property string label:      ""
    property string valueText:  "—"
    property color  valueColor: Constant.textLabel
    property real   gaugeRatio: 0.0   // 0.0 – 1.0, pre-clamped
    property color  gaugeColor: Constant.waiting
    property real   fs:         1.0   // font scale factor

    spacing: 8

    // Vertical gauge bar
    Rectangle {
        implicitWidth:  8
        implicitHeight: 50
        radius: 4
        color:  Constant.gaugeBg
        clip:   true

        Rectangle {
            anchors.bottom: parent.bottom
            width:  parent.width
            height: parent.height * root.gaugeRatio
            radius: 4
            color:  root.gaugeColor
            Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            Behavior on color  { ColorAnimation  { duration: 250 } }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        RowLayout {
            spacing: 4
            Image { source: root.iconSource }
            Text {
                text:           root.label
                color:          Constant.textLabel
                font.pixelSize: 15 * root.fs
                elide:          Text.ElideRight
            }
        }

        Text {
            text:             root.valueText
            color:            root.valueColor
            font.pixelSize:   19 * root.fs
            font.bold:        true
            elide:            Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
