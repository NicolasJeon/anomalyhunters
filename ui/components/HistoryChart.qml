pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtFacility

// 히스토리 바 차트 (Normal 모드) + Test with Data 입력 (Test 모드) 통합
//
// Normal 모드: 최근 10개 시계열 샘플을 온도/전력 바 차트로 시각화
// Test  모드: 최대 10개 샘플을 직접 입력해 추론 테스트
ColumnLayout {
    id: root

    // ── 속성 ───────────────────────────────────────────────────────────────
    property var    timeSeries: []       // 표시할 시계열 샘플 목록
    property bool   canTest:    false    // Test 모드 진입 가능 여부 (stopped 상태)
    property bool   testMode:   false    // 현재 Test 모드 여부
    property string equipmentId: ""     // 추론 요청 시 사용할 장비 ID

    // 온도/전력 도메인 (바 높이 계산에 사용)
    readonly property real tempMin:  28.0
    readonly property real tempMax:  70.0
    readonly property real pwrMin:   40.0
    readonly property real pwrMax:  130.0

    signal testToggled()
    signal previewChanged(var series)

    property real testTemperature: 35.0
    property real testPower:       55.0

    function collectSeries() {
        return [{ "temperature": root.testTemperature, "power": root.testPower,
                  "label": -1, "probAbnormal": 0 }]
    }
    function notifyPreview() { previewChanged(collectSeries()) }

    spacing: 6

    // ── 인라인 컴포넌트: 센서 바 차트 ────────────────────────────────────
    component SensorBar: ColumnLayout {
        id: bar
        required property string label        // 헤더 텍스트
        required property string valueKey     // sample 딕셔너리 키 ("temperature" | "power")
        required property real   valueMin
        required property real   valueMax
        required property color  normalColor  // label==0 일 때 바 색상

        property var timeSeries: []           // 부모에서 주입

        Layout.fillWidth: true
        spacing: 4

        Text { text: bar.label; color: Constant.textMuted; font.pixelSize: 10 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 2

            Repeater {
                model: 10
                delegate: Item {
                    id:               slot
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight:   50

                    readonly property var sample: {
                        const ts     = bar.timeSeries
                        const offset = ts.length - 10 + slot.index
                        return offset >= 0 ? ts[offset] : null
                    }
                    readonly property real barHeight: slot.sample !== null
                        ? Math.max(2, ((slot.sample[bar.valueKey] - bar.valueMin)
                                       / (bar.valueMax - bar.valueMin)) * 50)
                        : 0
                    readonly property color barColor: {
                        if (slot.sample === null) return "transparent"
                        const lbl = slot.sample["label"]
                        if (lbl === 0) return bar.normalColor
                        if (lbl === 1) return Constant.gaugeWarning
                        if (lbl === 2) return Constant.anomaly
                        return Constant.textMuted
                    }

                    // 빈 슬롯 배경
                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color:  Constant.chartSlotBg
                        visible: slot.sample === null
                    }
                    // 데이터 바
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width:   parent.width
                        height:  slot.barHeight
                        radius:  2
                        visible: slot.sample !== null
                        color:   slot.barColor
                    }
                }
            }
        }
    }

    // ── 헤더 행 ────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: root.testMode
                  ? "Test with Data"
                  : "History  (" + root.timeSeries.length + " samples)"
            color: Constant.textLabel
            font.pixelSize: 13
        }

        Item { Layout.fillWidth: true }

        // Run 버튼 (Test 모드에서만 표시)
        AppButton {
            visible: root.testMode
            implicitWidth: 130
            label: "▶  Run Inference"
            bgColor: "#0f2a18"
            hoverColor: "#1a4a2a"
            textColor: "#55ee88"
            fontSize: 12
            borderColor: "#338855"
            onClicked: equipmentManager.runTestSeries(root.equipmentId, root.collectSeries()) // qmllint disable unqualified
        }

        // Test with Data 토글 버튼
        AppButton {
            visible: root.canTest
            implicitWidth: 120
            label: root.testMode ? "✕ Close Test" : "⚗ Test with Data"
            bgColor:    root.testMode ? "#1a0830" : "#111a11"
            hoverColor: root.testMode ? "#2a1040" : "#1a2a1a"
            textColor:  root.testMode ? "#cc88ff" : "#55bb77"
            borderColor: root.testMode ? "#aa44ff" : "#336644"
            fontSize: 12
            onClicked: root.testToggled()
        }
    }

    // ── Normal 모드: 히스토리 바 차트 ──────────────────────────────────────
    ColumnLayout {
        visible: !root.testMode
        Layout.fillWidth: true
        spacing: 4

        SensorBar {
            timeSeries:  root.timeSeries
            label:       "Temperature  " + root.tempMin.toFixed(0) + " – " + root.tempMax.toFixed(0) + " °C"
            valueKey:    "temperature"
            valueMin:    root.tempMin
            valueMax:    root.tempMax
            normalColor: Constant.gaugeTemp
        }

        SensorBar {
            timeSeries:  root.timeSeries
            label:       "Power  " + root.pwrMin.toFixed(0) + " – " + root.pwrMax.toFixed(0) + " W"
            valueKey:    "power"
            valueMin:    root.pwrMin
            valueMax:    root.pwrMax
            normalColor: Constant.gaugePower
        }
    }

    // ── Test 모드: 단일 샘플 입력 ─────────────────────────────────────────
    Item {
        visible:          root.testMode
        Layout.fillWidth: true
        implicitHeight:   tempCol.implicitHeight

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            // 온도 입력
            Column {
                id:      tempCol
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Temperature (°C)"
                    color:          Constant.logSubText
                    font.pixelSize: 14
                }
                Rectangle {
                    width:        160
                    height:       44
                    color:        Constant.bgPanel
                    border.color: "#2a4a5a"
                    radius:       4
                    TextInput {
                        anchors { fill: parent; margins: 6 }
                        color:               Constant.sensorTemp
                        font.pixelSize:      22
                        font.family:         "Courier New"
                        text:                root.testTemperature.toFixed(1)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        inputMethodHints:    Qt.ImhFormattedNumbersOnly
                        onEditingFinished: {
                            var v = Math.max(root.tempMin, Math.min(root.tempMax, parseFloat(text) || root.tempMin))
                            root.testTemperature = v
                            text = v.toFixed(1)
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           root.tempMin.toFixed(0) + " – " + root.tempMax.toFixed(0) + " °C"
                    color:          Constant.textLabel
                    font.pixelSize: 11
                }
            }

            // 전력 입력
            Column {
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Power (W)"
                    color:          Constant.logSubText
                    font.pixelSize: 14
                }
                Rectangle {
                    width:        160
                    height:       44
                    color:        Constant.bgPanel
                    border.color: "#2a3a5a"
                    radius:       4
                    TextInput {
                        anchors { fill: parent; margins: 6 }
                        color:               Constant.sensorPower
                        font.pixelSize:      22
                        font.family:         "Courier New"
                        text:                root.testPower.toFixed(1)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        inputMethodHints:    Qt.ImhFormattedNumbersOnly
                        onEditingFinished: {
                            var v = Math.max(root.pwrMin, Math.min(root.pwrMax, parseFloat(text) || root.pwrMin))
                            root.testPower = v
                            text = v.toFixed(1)
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           root.pwrMin.toFixed(0) + " – " + root.pwrMax.toFixed(0) + " W"
                    color:          Constant.textLabel
                    font.pixelSize: 11
                }
            }
        }
    }
}
