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
    property bool   recording:        false

    property bool testMode:    false
    property var  testSeries:  []

    signal startRequested()
    signal stopRequested()
    signal emergencyRequested()
    signal resetRequested()
    signal editRequested()

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
            onStartRequested:     { root.testMode = false; root.startRequested() }
            onStopRequested:      root.stopRequested()
            onEmergencyRequested: root.emergencyRequested()
            onResetRequested:     root.resetRequested()
            onEditRequested:      root.editRequested() // qmllint disable unqualified
        }

        // ② 미들 로우: [이미지 2] [통합 상태 카드 3]
        RowLayout {
            id: midRow
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            Layout.minimumHeight:   140
            spacing: 10

            ImageCard {
                Layout.preferredWidth: (midRow.width - midRow.spacing) * 2 / 5
                Layout.fillHeight: true
                imageSource: root.selDev["imageSource"] ?? ""
                deviceType:  root.selDev["type"]        ?? ""
            }

            StatusCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                controlStatus: root.selDev["controlStatus"]          ?? "stopped"
                label:         root.selInf["label"]                  ?? -1
                statusText:    root.selInf["statusText"]             ?? "—"
                probNormal:    root.selInf["probNormal"]             ?? 0
                probWarning:   root.selInf["probWarning"]            ?? 0
                probAbnormal:  root.selInf["probAbnormal"]           ?? 0
                hasData:       root.selTS.length > 0
                temperature:   root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["temperature"] : 0
                power:         root.selTS.length > 0 ? root.selTS[root.selTS.length-1]["power"]       : 0
                recording:     root.recording
                testMode:      root.testMode // qmllint disable missing-property
                onRecordToggled: repository.toggleRecording(root.selectedDeviceId) // qmllint disable unqualified
            }
        }

        // ③ 히스토리 차트 (normal) + Test with Data 입력 (test mode) 통합
        HistoryChart {
            Layout.fillWidth: true
            Layout.preferredHeight: root.testMode ? -1  : 160
            Layout.fillHeight:      root.testMode
            Layout.minimumHeight:   160
            timeSeries: root.testMode ? root.testSeries : root.selTS
            canTest:    (root.selDev["controlStatus"] ?? "stopped") === "stopped"
            testMode:   root.testMode
            deviceId:   root.selectedDeviceId
            onTestToggled: { // qmllint disable unqualified
                root.testMode = !root.testMode
                if (root.testMode) {
                    repository.clearDeviceDisplay(root.selectedDeviceId)
                } else {
                    root.testSeries = []
                }
            }
            onPreviewChanged: (series) => root.testSeries = series // qmllint disable unqualified
        }

        // 빈 공간 채우기 (normal 모드에서 HistoryChart 아래 여백)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.testMode
        }
    }
}
