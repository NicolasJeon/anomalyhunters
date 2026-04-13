import QtQuick
import QtQuick.Layouts
import QtGraphs
import QtFacility

// 히스토리 라인 그래프 (Normal 모드) + Test with Data 입력 (Test 모드) 통합
ColumnLayout {
    id: root

    // ── 속성 ───────────────────────────────────────────────────────────────
    property var    timeSeries:  []
    property bool   canTest:     false
    property bool   testMode:    false
    property string equipmentId: ""

    readonly property int currentLabel: {
        if (timeSeries.length === 0) return -1
        return timeSeries[timeSeries.length - 1]["label"] ?? -1
    }
    readonly property color _tempDotColor:
        currentLabel === 2 ? Constant.anomaly :
        currentLabel === 1 ? Constant.warning : Constant.sensorTemp

    readonly property color _pwrDotColor:
        currentLabel === 2 ? Constant.anomaly :
        currentLabel === 1 ? Constant.warning : Constant.sensorPower

    readonly property real tempMin:  28.0
    readonly property real tempMax:  70.0
    readonly property real pwrMin:   40.0
    readonly property real pwrMax:  120.0

    signal testToggled()
    signal previewChanged(var series)

    property real testTemperature: 35.0
    property real testPower:       55.0

    function collectSeries() {
        return [{ "temperature": root.testTemperature, "power": root.testPower,
                  "label": -1, "abnormalDist": 0 }]
    }
    function notifyPreview() { previewChanged(collectSeries()) }

    function _norm(val, mn, mx) { return (val - mn) / (mx - mn) * 100.0 }

    function _updateSeries() {
        tempSeries.clear()
        pwrSeries.clear()
        const ts = root.timeSeries
        if (ts.length === 0) return
        const t0 = ts[0]["timestampMs"] ?? 0
        for (let i = 0; i < ts.length; i++) {
            const sec = ((ts[i]["timestampMs"] ?? 0) - t0) / 1000.0
            tempSeries.append(sec, _norm(ts[i]["temperature"] ?? root.tempMin, root.tempMin, root.tempMax))
            pwrSeries.append(sec, _norm(ts[i]["power"]        ?? root.pwrMin,  root.pwrMin,  root.pwrMax))
        }
        const rawMax = ((ts[ts.length - 1]["timestampMs"] ?? 0) - t0) / 1000.0
        const xMax = Math.max(10, Math.ceil(rawMax / 5) * 5)
        axisX.max = xMax
    }

    onTimeSeriesChanged: _updateSeries()

    spacing: 6

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

        AppButton {
            visible: root.canTest
            implicitWidth: 120
            label: root.testMode ? "✕ Close Test" : "⚗ Test with Data"
            bgColor:     root.testMode ? "#1a0830" : "#111a11"
            hoverColor:  root.testMode ? "#2a1040" : "#1a2a1a"
            textColor:   root.testMode ? "#cc88ff" : "#55bb77"
            borderColor: root.testMode ? "#aa44ff" : "#336644"
            fontSize: 12
            onClicked: root.testToggled()
        }
    }

    // ── Normal 모드: 통합 그래프 ───────────────────────────────────────────
    ColumnLayout {
        visible:          !root.testMode
        Layout.fillWidth: true
        spacing: 4

        GraphsView {
            Layout.fillWidth: true
            implicitHeight:   140
            marginLeft:       0
            marginRight:      0
            marginTop:        0
            marginBottom:     0

            theme: GraphsTheme {
                backgroundColor:           Constant.chartSlotBg
                plotAreaBackgroundColor:   Constant.chartSlotBg
                plotAreaBackgroundVisible: true
                gridVisible:               false
                labelFont.pixelSize:       10
                labelTextColor:            Constant.textMuted
                seriesColors:              [Constant.sensorTemp, Constant.sensorPower]
            }

            axisX: ValueAxis {
                id:           axisX
                min:          0
                max:          9
                gridVisible:  false
                subTickCount: 0
                tickInterval: 5
                labelFormat:  "%.0fs"
            }
            axisY: ValueAxis {
                id:           axisY
                min:          0
                max:          100
                tickInterval: 50
                subTickCount: 0
                labelFormat:  "%.0f%%"
            }

            LineSeries {
                id:    tempSeries
                width: 2
                pointDelegate: Rectangle {
                    width: 6; height: 6; radius: 3
                    color: root._tempDotColor
                }
            }
            LineSeries {
                id:    pwrSeries
                width: 2
                pointDelegate: Rectangle {
                    width: 6; height: 6; radius: 3
                    color: root._pwrDotColor
                }
            }
        }

        // ── 범례 ─────────────────────────────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Row {
                spacing: 5
                Rectangle { width: 16; height: 2; color: Constant.sensorTemp; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "Temp  " + root.tempMin.toFixed(0) + " - " + root.tempMax.toFixed(0) + " C"
                    color: Constant.sensorTemp; font.pixelSize: 10
                }
            }
            Row {
                spacing: 5
                Rectangle { width: 16; height: 2; color: Constant.sensorPower; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "Power  " + root.pwrMin.toFixed(0) + " - " + root.pwrMax.toFixed(0) + " W"
                    color: Constant.sensorPower; font.pixelSize: 10
                }
            }
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

            Column {
                id:      tempCol
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Temperature (C)"
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
                    text:           root.tempMin.toFixed(0) + " - " + root.tempMax.toFixed(0) + " C"
                    color:          Constant.textLabel
                    font.pixelSize: 11
                }
            }

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
                    text:           root.pwrMin.toFixed(0) + " - " + root.pwrMax.toFixed(0) + " W"
                    color:          Constant.textLabel
                    font.pixelSize: 11
                }
            }
        }
    }
}
