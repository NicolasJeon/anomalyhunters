import QtQuick
import QtQuick.Layouts
import QtFacility

// 통합 상태 카드 — 상태+게이지 한 줄 / 센서 수치
Rectangle {
    id: root

    property string controlStatus: "Stopped"
    property int    label:         -1
    property string statusText:    "—"
    property real   abnormalDist:  0.0
    property bool   hasData:       false
    property real   temperature:   0.0
    property real   power:         0.0
    property bool   testMode:      false

    // 폰트 스케일 — 카드 너비 450px 기준, 창 크기에 따라 비례
    readonly property real _fs: Math.max(0.55, Math.min(1.4, root.width / 450))

    // 애니메이션용 표시값 — 실제값으로 부드럽게 보간
    property real _dispTemp:  0.0
    property real _dispPower: 0.0

    Behavior on _dispTemp  { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on _dispPower { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    onTemperatureChanged: if (root.hasData) _dispTemp  = root.temperature
    onPowerChanged:       if (root.hasData) _dispPower = root.power
    onHasDataChanged:     if (!root.hasData) { _dispTemp = 0; _dispPower = 0 }

    radius: 6
    color: Constant.bgCard

    readonly property color _statusColor: {
        if (root.controlStatus === "Stopped" && !root.testMode)  return Constant.stopped
        if (root.label === -1) return Constant.waiting
        if (root.label ===  0) return Constant.normal
        if (root.label ===  1) return Constant.warning
        return Constant.anomaly
    }

    readonly property color _rightBarColor:
        root.label === 1 ? Constant.warning : Constant.gaugeAbnormal

    ColumnLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 10

        // ── ① 상태 텍스트 ─────────────────────────────────────────────────
        ColumnLayout {
            spacing: 4
            RowLayout {
                spacing: 8
                Text { text: "Health Status"; color: Constant.textLabel; font.pixelSize: 16 * root._fs }
                Rectangle {
                    visible: root.testMode
                    implicitWidth: testModeLabel.implicitWidth + 10
                    implicitHeight: testModeLabel.implicitHeight + 4
                    radius: 3
                    color: Constant.testModeBg
                    border.color: Constant.testModeBorder
                    border.width: 1
                    Text {
                        id: testModeLabel
                        anchors.centerIn: parent
                        text: "Test Mode"
                        color: Constant.testModeText
                        font.pixelSize: 11 * root._fs
                    }
                }
            }
            RowLayout {
                spacing: 8
                Rectangle {
                    implicitWidth: 10
                    implicitHeight: 10
                    radius: 5
                    color: root._statusColor
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
                Text {
                    text: (root.controlStatus === "Stopped" && !root.testMode) ? "Stopped"
                        : (root.testMode && root.label === -1)                 ? "Waiting"
                        : root.statusText
                    color: root._statusColor
                    font.pixelSize: 19 * root._fs
                    font.bold: true
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }

        // ── ② Abnormal 근접도 게이지 ─────────────────────────────────────
        Text { text: "Abnormal Proximity"; color: Constant.textLabel; font.pixelSize: 16 * root._fs }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 10
                radius: 3
                color: Constant.gaugeBg

                Rectangle {
                    anchors.left: parent.left
                    width: parent.width * root.abnormalDist
                    height: parent.height
                    radius: 3
                    color: root._statusColor
                    Behavior on width { NumberAnimation { duration: 200 } }
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }

            Text {
                text: root.label === -1 ? "—" : (root.abnormalDist * 100).toFixed(0) + "%"
                color: root._statusColor
                font.pixelSize: 16 * root._fs
                font.bold: true
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        // ── 구분선 ────────────────────────────────────────────────────────
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // ── ③ 센서 수치 ───────────────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 0
            rowSpacing: 4

            Text {
                text: "Temperature"
                color: Constant.textLabel
                font.pixelSize: 15 * root._fs
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                text: "Power"
                color: Constant.textLabel
                font.pixelSize: 15 * root._fs
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.hasData ? Constant.formatTemp(root._dispTemp) : "—"
                color: Constant.sensorTemp
                font.pixelSize: 19 * root._fs
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                text: root.hasData ? Constant.formatPower(root._dispPower) : "—"
                color: Constant.sensorPower
                font.pixelSize: 19 * root._fs
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

    }

}
