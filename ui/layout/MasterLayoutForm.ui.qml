import QtQuick
import "../components"

Rectangle {
    id: root

    signal addRequested()

    color: Constant.bgPanel

    // ── header ────────────────────────────────────────────────────────────────
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 46
        color:  Constant.bgPanel

        Text {
            anchors {
                left:           parent.left
                leftMargin:     14
                verticalCenter: parent.verticalCenter
            }
            text:           "Equipment"
            color:          Constant.textHeader
            font.pixelSize: 15
            font.bold:      true
        }

        AppButton {
            anchors {
                right:          parent.right
                rightMargin:    12
                verticalCenter: parent.verticalCenter
            }
            implicitWidth:  26
            implicitHeight: 22
            label:          "+"
            bold:           true
            fontSize:       16
            bgColor:        Constant.btnAdd.bg
            hoverColor:     Constant.btnAdd.bgHov
            textColor:      Constant.btnAdd.text
            borderColor:    Constant.btnAdd.border
            onClicked:      root.addRequested()
        }
    }

    // ── divider ───────────────────────────────────────────────────────────────
    Rectangle {
        id: divider
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        height: 1
        color:  Constant.border
    }

    // ── equipment list ────────────────────────────────────────────────────────
    EquipmentList {
        anchors { top: divider.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
    }
}
