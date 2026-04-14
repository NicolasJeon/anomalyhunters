import QtQuick
import QtQuick.Layouts
import "../components"

// 우측 DETAIL 레이아웃 — 구조/스타일 전용
Rectangle {
    id: root

    // ── 외부 데이터 ───────────────────────────────────────────────────────
    property var    selDev:              ({})
    property var    selInf:              ({})
    property var    selTS:               []
    property string selectedEquipmentId: ""

    // ── 내부 UI 상태 ──────────────────────────────────────────────────────
    property bool testMode:   false
    property var  testSeries: []

    // ── 자식 노출 ─────────────────────────────────────────────────────────
    property alias equipmentHeader: equipmentHeader
    property alias statusCard:      statusCard
    property alias historyChart:    historyChart
    property alias stateLogPanel:   stateLogPanel

    color: "#12141f"

    // 장비 미선택 안내
    Text {
        anchors.centerIn: parent
        visible:          root.selectedEquipmentId === ""
        text:             "← Select equipment"
        color:            "#444466"
        font.pixelSize:   18
    }

    // ── 상세 뷰 (장비가 선택된 경우) ──────────────────────────────────────
    ColumnLayout {
        anchors {
            fill:    parent
            margins: 16
        }
        spacing: 12
        visible: root.selectedEquipmentId !== ""

        // ① 헤더: 이름 / 제어 버튼
        EquipmentHeader {
            id:            equipmentHeader
            Layout.fillWidth: true
            name:          root.selDev["name"]          ?? ""
            controlStatus: root.selDev["controlStatus"] ?? "Stopped"
        }

        // ② 이미지 카드 + 상태 카드
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
                testMode:      root.testMode
            }
        }

        // ③ 히스토리 차트
        HistoryChart {
            id:                    historyChart
            Layout.fillWidth:      true
            Layout.preferredHeight: root.testMode ? root.height * 0.3 : 160
            Layout.minimumHeight:  160
            timeSeries:  root.testMode ? root.testSeries : root.selTS
            canTest:     (root.selDev["controlStatus"] ?? "Stopped") === "Stopped"
            testMode:    root.testMode
            equipmentId: root.selectedEquipmentId
        }

        // ④ 상태 로그
        StateLogPanel {
            id:                   stateLogPanel
            Layout.fillWidth:     true
            Layout.fillHeight:    true
            Layout.minimumHeight: 100
            visible:              !root.testMode
            equipmentId:          root.selectedEquipmentId
            equipmentName:        root.selDev["name"] ?? ""
            temperature:          root.selTS.length > 0 ? root.selTS[root.selTS.length - 1]["temperature"] : 0
            power:                root.selTS.length > 0 ? root.selTS[root.selTS.length - 1]["power"]       : 0
        }
    }
}
