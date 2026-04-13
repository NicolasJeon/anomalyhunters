import QtQuick
import QtQuick.Layouts
import "../components"

// 좌측 MASTER 레이아웃 — 구조/스타일 전용
Rectangle {
    id: root

    property var    equipment:           []
    property string selectedEquipmentId: ""

    // ── 자식 노출 (로직 파일에서 Connections 연결용) ───────────────────────
    property alias equipmentList: equipmentList
    property alias btnAdd:        btnAdd
    property alias btnStartAll:   btnStartAll
    property alias btnStopAll:    btnStopAll

    color: "#0e1020"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── 헤더: 제목 + 장비 추가 버튼 ──────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   46
            color:            "#181a2e"

            RowLayout {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left:           parent.left
                    leftMargin:     12
                }
                spacing: 8

                Text {
                    text:           "Equipment"
                    color:          "#c0c0e0"
                    font.pixelSize: 15
                    font.bold:      true
                }

                AppButton {
                    id:            btnAdd
                    implicitWidth:  26
                    implicitHeight: 22
                    label:          "+"
                    bold:           true
                    fontSize:       16
                    bgColor:        Constant.ctrlStartBg
                    hoverColor:     Constant.ctrlStartBgHov
                    textColor:      Constant.ctrlStartText
                }
            }
        }

        // ── 장비 목록 ─────────────────────────────────────────────────────
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

        // ── 하단: 전체 제어 버튼 ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   44
            color:            "#0e1020"

            Rectangle {
                anchors {
                    top:   parent.top
                    left:  parent.left
                    right: parent.right
                }
                height: 1
                color:  "#2a2c4e"
            }

            Row {
                anchors {
                    fill:    parent
                    margins: 6
                }
                spacing: 6

                AppButton {
                    id:          btnStartAll
                    width:       (parent.width - 6) / 2
                    height:      parent.height
                    label:       "Start All"
                    bold:        true
                    fontSize:    12
                    bgColor:     Constant.ctrlStartBg
                    hoverColor:  Constant.ctrlStartBgHov
                    textColor:   Constant.ctrlStartText
                    borderColor: Constant.ctrlStartBorder
                }

                AppButton {
                    id:        btnStopAll
                    width:     (parent.width - 6) / 2
                    height:    parent.height
                    label:     "Stop All"
                    bold:      true
                    fontSize:  12
                    bgColor:    Constant.ctrlStopBg
                    hoverColor: Constant.ctrlStopBgHov
                    textColor:  Constant.ctrlStopText
                }
            }
        }
    }
}
