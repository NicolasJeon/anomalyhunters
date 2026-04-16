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
        color:          "#7777aa"
        font.pixelSize: 11
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight:   32
        radius:           4
        color:            "#0e1020"
        border.color:     input.activeFocus ? Constant.inputFocusBorder : Constant.border

        TextInput {
            id: input
            anchors { fill: parent; margins: 8 }
            color:            "#d0d0ee"
            font.pixelSize:   13
            inputMethodHints: root.inputHints
            Keys.onReturnPressed: root.returnPressed()
        }
        Text {
            anchors { fill: parent; margins: 8 }
            text:           root.placeholder
            color:          "#444466"
            font.pixelSize: 13
            visible:        input.text === ""
        }
    }
}
