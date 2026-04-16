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

    color: "#0e1020"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── header ────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   46
            color:            "#181a2e"

            Text {
                anchors {
                    left:           parent.left
                    leftMargin:     14
                    verticalCenter: parent.verticalCenter
                }
                text:           "Equipment"
                color:          "#c0c0e0"
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
                bgColor:        "#2a2060"
                hoverColor:     "#3a30a0"
                textColor:      "#818cf8"
                borderColor:    "#4a40a0"
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
            color:            "#0e1020"

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1
                color:  "#2a2c4e"
            }

            Row {
                anchors.centerIn: parent
                spacing: 6

                Text { text: root.countTotal + " Devices"; color: "#7777aa"; font.pixelSize: 11 }
                Text { text: "·"; color: "#333355"; font.pixelSize: 11 }
                Text {
                    text:           root.countAbnormal + " Abnormal"
                    color:          root.countAbnormal > 0 ? "#cc3344" : "#444466"
                    font.pixelSize: 11
                }
                Text { text: "·"; color: "#333355"; font.pixelSize: 11 }
                Text {
                    text:           root.countWarning + " Warning"
                    color:          root.countWarning > 0 ? "#d89050" : "#444466"
                    font.pixelSize: 11
                }
            }
        }

        // ── Start All / Stop All ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   36
            color:            "#0e1020"

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#1e2040"
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
