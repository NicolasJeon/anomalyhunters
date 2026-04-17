import QtQuick
import QtQuick.Layouts
import "../components"

// Master panel — structure only
// qmllint disable unqualified
Rectangle {
    id: root

    property var    equipment:           []
    property string selectedEquipmentId: ""

    // bound in MasterLayout.qml
    property int countTotal:    0
    property int countNormal:   0
    property int countWarning:  0
    property int countAbnormal: 0

    // ── exposed aliases ───────────────────────────────────────────────────────
    property alias equipmentList: equipmentList
    property alias btnAdd:        btnAdd
    property alias btnStartAll:   btnStartAll
    property alias btnStopAll:    btnStopAll

    color: Constant.bgDialog

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── header ────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   46
            color:            Constant.bgDialog

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
                id:            btnAdd
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
            }
        }

        // ── equipment list ────────────────────────────────────────────────────
        ListView {
            id:               equipmentList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip:             true
            model:            root.equipment

            delegate: EquipmentListItem {
                required property var modelData
                width:         ListView.view.width
                equipmentData: modelData
                isSelected:    modelData["id"] === root.selectedEquipmentId
            }
        }

        // ── stats bar ─────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   36
            color:            Constant.bgDialog

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1
                color:  Constant.border
            }

            Row {
                anchors.centerIn: parent
                spacing: 6

                Text { text: root.countTotal + " Devices"; color: Constant.textLabel; font.pixelSize: 11 }
                Text { text: "·"; color: Constant.statsDot; font.pixelSize: 11 }
                Text {
                    text:           root.countAbnormal + " Abnormal"
                    color:          root.countAbnormal > 0 ? Constant.anomaly : "#444466"
                    font.pixelSize: 11
                }
                Text { text: "·"; color: Constant.statsDot; font.pixelSize: 11 }
                Text {
                    text:           root.countWarning + " Warning"
                    color:          root.countWarning > 0 ? Constant.warning : "#444466"
                    font.pixelSize: 11
                }
            }
        }

        // ── Start All / Stop All ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   36
            color:            Constant.bgDialog

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: Constant.dividerDark
            }

            Row {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 6; bottomMargin: 6 }
                spacing: 8

                AppButton {
                    id:          btnStartAll
                    width:       (parent.width - parent.spacing) / 2
                    height:      parent.height
                    label:       "Start All"
                    fontSize:    11
                    bgColor:     Constant.ctrlStart.bg
                    hoverColor:  Constant.ctrlStart.bgHov
                    textColor:   Constant.ctrlStart.text
                    borderColor: Constant.ctrlStart.border
                }

                AppButton {
                    id:          btnStopAll
                    width:       (parent.width - parent.spacing) / 2
                    height:      parent.height
                    label:       "Stop All"
                    fontSize:    11
                    bgColor:     Constant.ctrlStop.bg
                    hoverColor:  Constant.ctrlStop.bgHov
                    textColor:   Constant.ctrlStop.text
                }
            }
        }
    }
}
