import QtQuick
import QtQuick.Layouts
import "../components"

// Detail panel — structure only
Rectangle {
    id: root

    // ── data inputs ───────────────────────────────────────────────────────────
    property var    selDev:              ({})
    property var    selInf:              ({})
    property var    selTS:               []
    property string selectedEquipmentId: ""

    // ── exposed aliases ───────────────────────────────────────────────────────
    property alias equipmentHeader: equipmentHeader
    property alias statusCard:      statusCard
    property alias historyChart:    historyChart
    property alias stateLogPanel:   stateLogPanel

    color: Constant.bgDetail

    // no-selection placeholder
    Text {
        anchors.centerIn: parent
        visible:          root.selectedEquipmentId === ""
        text:             "← Select equipment"
        color:            Constant.textMuted
        font.pixelSize:   18
    }

    // ── detail view ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors {
            fill:    parent
            margins: 16
        }
        spacing: 12
        visible: root.selectedEquipmentId !== ""

        // ① header
        EquipmentHeader {
            id:            equipmentHeader
            Layout.fillWidth: true
            name:          root.selDev["name"]          ?? ""
            controlStatus: root.selDev["controlStatus"] ?? "Stopped"
        }

        // ② image + status card
        RowLayout {
            Layout.fillWidth:    true
            Layout.preferredHeight: 160
            Layout.minimumHeight:   140
            spacing: 10

            ImageCard {
                Layout.preferredWidth: (parent.width - parent.spacing) * 2 / 5
                Layout.fillHeight:     true
                imageSource: root.selDev["imageSource"] ?? ""
            }

            StatusCard {
                id:              statusCard
                Layout.fillWidth:  true
                Layout.fillHeight: true
                controlStatus: root.selDev["controlStatus"] ?? "Stopped"
                label:         root.selInf["label"]         ?? -1
                statusText:    root.selInf["statusText"]    ?? "—"
                hasData:       root.selTS.length > 0
                temperature:   root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["temperature"] : 0
                power:         root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["power"]       : 0
            }
        }

        // ③ history chart
        HistoryChart {
            id:                    historyChart
            Layout.fillWidth:      true
            Layout.preferredHeight: 160
            Layout.minimumHeight:  160
            timeSeries:  root.selTS
            equipmentId: root.selectedEquipmentId
        }

        // ④ state log
        StateLogPanel {
            id:                   stateLogPanel
            Layout.fillWidth:     true
            Layout.fillHeight:    true
            Layout.minimumHeight: 100
            equipmentId:          root.selectedEquipmentId
            equipmentName:        root.selDev["name"] ?? ""
            temperature:          root.selTS.length > 0 ? root.selTS[root.selTS.length - 1]["temperature"] : 0
            power:                root.selTS.length > 0 ? root.selTS[root.selTS.length - 1]["power"]       : 0
        }
    }
}
