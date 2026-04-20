import QtQuick
import QtQuick.Layouts
import "../components"

// qmllint disable unqualified missing-property
Rectangle {
    id: root

    color: Constant.bgWindow

    readonly property var    selDev: EquipmentManager.selectedEquipment
    readonly property string selId:  EquipmentManager.selectedEquipmentId

    // ── no-selection placeholder ──────────────────────────────────────────────
    Text {
        anchors.centerIn: parent
        visible:          root.selId === ""
        text:             "← 장비를 선택하세요"
        color:            Constant.textMuted
        font.pixelSize:   16
    }

    // ── detail view ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors { fill: parent; margins: 16 }
        spacing: 12
        visible: root.selId !== ""

        // ① equipment name header
        Text {
            text:           root.selDev["name"] ?? ""
            color:          Constant.textHeader
            font.pixelSize: 18
            font.bold:      true
        }

        // ② image + status card
        RowLayout {
            Layout.fillWidth:       true
            Layout.preferredHeight: 180
            spacing: 12

            ImageCard {
                Layout.preferredWidth: (parent.width - parent.spacing) * 2 / 5
                Layout.fillHeight:     true
                imageSource: root.selDev["imageSource"] ?? ""
            }

            StatusCard {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                controlStatus: "Running"
                hasData:       root.selId !== ""
                temperature:   EquipmentManager.selectedTemperature
                power:         EquipmentManager.selectedPower
            }
        }

        // ③ placeholder (step5: 그래프/로그 영역)
        Rectangle {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            color:             Constant.bgDetail
            radius:            8
            border.color:      Constant.border
            border.width:      1

            Text {
                anchors.centerIn: parent
                text:             "Graph / Log — step 5"
                color:            Constant.textMuted
                font.pixelSize:   13
            }
        }
    }
}
