import QtQuick
import QtQuick.Layouts
import "../components"

// 우측 DETAIL 패널 — 선택 장비 상세 정보
Rectangle {
    id: root

    property var    selDev:           ({})
    property var    selInf:           ({})
    property var    selTS:            []
    property string selectedDeviceId: ""

    signal startRequested()
    signal stopRequested()
    signal emergencyRequested()
    signal resetRequested()

    color: "#12141f"

    // ── 미선택 안내 ───────────────────────────────────────────────────────
    Text {
        anchors.centerIn: parent
        text: "← Select a device"
        color: "#444466"; font.pixelSize: 18
        visible: root.selectedDeviceId === ""
    }

    // ── 상세 뷰 ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: root.selectedDeviceId !== ""

        // ① 헤더: 이름 / 타입 / 제어 버튼
        DeviceHeader {
            Layout.fillWidth: true
            name:          root.selDev["name"]          ?? ""
            type:          root.selDev["type"]          ?? ""
            controlStatus: root.selDev["controlStatus"] ?? "stopped"
            onStartRequested:     root.startRequested()
            onStopRequested:      root.stopRequested()
            onEmergencyRequested: root.emergencyRequested()
            onResetRequested:     root.resetRequested()
        }

        // ② 미들 로우: [이미지] [추론 카드] [센서 카드]
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            spacing: 10

            ImageCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                imageSource: root.selDev["imageSource"] ?? ""
                deviceType:  root.selDev["type"]        ?? ""
            }

            InferenceCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                controlStatus: root.selDev["controlStatus"] ?? "stopped"
                label:         root.selInf["label"]         ?? -1
                statusText:    root.selInf["statusText"]    ?? "—"
                probAbnormal:  root.selInf["probAbnormal"]  ?? 0
            }

            SensorCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                hasData:      root.selTS.length > 0
                temperature:  root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["temperature"] : 0
                power:        root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["power"]       : 0
                label:        root.selInf["label"]        ?? -1
                probNormal:   root.selInf["probNormal"]   ?? 0
                probAbnormal: root.selInf["probAbnormal"] ?? 0
            }
        }

        // ③ 히스토리 차트
        HistoryChart {
            Layout.fillWidth: true
            timeSeries: root.selTS
        }

        // ④ 로그 리스트
        LogList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            timeSeries: root.selTS
        }
    }
}
