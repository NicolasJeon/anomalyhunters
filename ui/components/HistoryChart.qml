import QtQuick
import QtQuick.Layouts
import QtGraphs
import QtFacility

// History line chart
ColumnLayout {
    id: root

    property var    timeSeries:  []
    property string equipmentId: ""

    readonly property var _last: timeSeries.length > 0 ? timeSeries[timeSeries.length - 1] : null

    // qmllint disable missing-property
    readonly property color _tempColor: Constant.tempStateColor(_last ? (_last["temperature"] ?? 0) : 0, _last !== null)
    readonly property color _pwrColor:  Constant.pwrStateColor (_last ? (_last["power"]       ?? 0) : 0, _last !== null)
    // qmllint enable missing-property

    readonly property real tempMin:  0
    readonly property real tempMax:  70
    readonly property real pwrMin:   0
    readonly property real pwrMax:  120

    function _norm(val, mn, mx) { return (val - mn) / (mx - mn) * 100.0 }

    // ── Practice #11: 온도/전력 히스토리 그래프 ──────────────────────────────
    // Mission: temperature / power 두 개의 시계열 그래프를 구현하세요
    // Hints:   GraphsView 안에 LineSeries를 두 개 선언하세요 (tempSeries, pwrSeries)
    //          timeSeries 배열의 각 항목은 { timestampMs, temperature, power }

    function _updateSeries() {
        const ts = root.timeSeries
        if (ts.length === 0) return
        const t0 = ts[0]["timestampMs"] ?? 0

        // TODO: 주석을 해제하세요
        // tempSeries.clear()
        // pwrSeries.clear()

        for (let i = 0; i < ts.length; i++) {
            const sec = ((ts[i]["timestampMs"] ?? 0) - t0) / 1000.0

            // TODO: 주석을 해제하세요
            // tempSeries.append(sec, _norm(ts[i]["temperature"], root.tempMin, root.tempMax))
            // pwrSeries.append (sec, _norm(ts[i]["power"],       root.pwrMin,  root.pwrMax ))
        }

        const rawMax = ((ts[ts.length - 1]["timestampMs"] ?? 0) - t0) / 1000.0
        // qmllint disable unqualified
        axisX.max = Math.max(10, Math.ceil(rawMax / 5) * 5)
        // qmllint enable unqualified
    }

    onTimeSeriesChanged: _updateSeries()

    spacing: 6

    Text {
        text:           "History"
        color:          Constant.textLabel
        font.bold:      true
        font.pixelSize: 13
    }

    GraphsView {
        Layout.fillWidth: true
        implicitHeight:   140
        marginLeft:       0
        marginRight:      0
        marginTop:        0
        marginBottom:     0

        theme: GraphsTheme {
            backgroundColor:           Constant.bgDetail
            plotAreaBackgroundColor:   Constant.bgDetail
            plotAreaBackgroundVisible: true
            gridVisible:               false
            labelFont.pixelSize:       10
            labelTextColor:            Constant.textMuted
            seriesColors: [Constant.sensorTemp, Constant.sensorPower]
        }

        // TODO: 주석을 해제하세요
        // axisX: ValueAxis {
        //     id:           axisX
        //     min:          0
        //     max:          9
        //     gridVisible:  false
        //     subTickCount: 0
        //     tickInterval: 5
        //     labelFormat:  "%.0fs"
        // }
        // axisY: ValueAxis {
        //     id:           axisY
        //     min:          0
        //     max:          100
        //     tickInterval: 50
        //     subTickCount: 0
        //     labelFormat:  "%.0f%%"
        // }

        // TODO: 주석을 해제하세요
        // LineSeries {
        //     id:    tempSeries
        //     width: 2
        // }
        // LineSeries {
        //     id:    pwrSeries
        //     width: 2
        // }
    }

    // Legend
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 16

        Row {
            spacing: 5
            Rectangle { width: 16; height: 2; color: Constant.sensorTemp; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text:  "Temp  " + root.tempMin.toFixed(0) + " - " + root.tempMax.toFixed(0) + " C"
                color: Constant.sensorTemp; font.pixelSize: 10
            }
        }
        Row {
            spacing: 5
            Rectangle { width: 16; height: 2; color: Constant.sensorPower; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text:  "Power  " + root.pwrMin.toFixed(0) + " - " + root.pwrMax.toFixed(0) + " W"
                color: Constant.sensorPower; font.pixelSize: 10
            }
        }
    }
}
