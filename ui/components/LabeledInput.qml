import QtQuick
import QtQuick.Layouts
import QtFacility

// Labeled text input: title + bordered TextInput + placeholder
ColumnLayout {
    id: root

    property string label:       ""
    property string placeholder: ""
    property alias  text:        input.text
    property int    inputHints:  Qt.ImhNone

    signal returnPressed()

    function forceActiveFocus() { input.forceActiveFocus() }

    spacing: 5

    Text {
        text:           root.label
        color:          Constant.textHeader
        font.pixelSize: 13
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight:   36
        radius:           4
        color:            Constant.bgPanel
        border.color:     input.activeFocus ? Constant.inputFocusBorder : Constant.border

        TextInput {
            id: input
            anchors { fill: parent; margins: 8 }
            color:            Constant.textPrimary
            font.pixelSize:   15
            inputMethodHints: root.inputHints
            Keys.onReturnPressed: root.returnPressed()
        }
        Text {
            anchors { fill: parent; margins: 8 }
            text:           root.placeholder
            color:          Constant.textSecondary
            font.pixelSize: 15
            visible:        input.text === ""
        }
    }
}
