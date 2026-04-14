import QtQuick
import QtQuick.Layouts
import QtFacility

// Combined status card: health status + sensor values with vertical bars
Rectangle {
    id: root

    property string controlStatus: "Stopped"
    property int    label:         -1
    property string statusText:    "—"
    property bool   hasData:       false
    property real   temperature:   0.0
    property real   power:         0.0
    property bool   testMode:      false

    // Font scale: normalized to 450px card width
    readonly property real _fs: Math.max(0.55, Math.min(1.4, root.width / 450))

    // Animated display values
    property real _dispTemp:  0.0
    property real _dispPower: 0.0

    Behavior on _dispTemp  { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on _dispPower { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    onTemperatureChanged: if (root.hasData) _dispTemp  = root.temperature
    onPowerChanged:       if (root.hasData) _dispPower = root.power
    onHasDataChanged:     if (!root.hasData) { _dispTemp = 0; _dispPower = 0 }

    radius: 6
    color: Constant.bgCard

    // Overall health color (based on finalState label)
    readonly property color _statusColor: {
        if (root.controlStatus === "Stopped" && !root.testMode) return Constant.stopped
        if (root.label === -1) return Constant.waiting
        if (root.label ===  0) return Constant.normal
        if (root.label ===  1) return Constant.warning
        return Constant.anomaly
    }

    // Per-sensor state colors (independent thresholds)
    readonly property color _tempStateColor: {
        if (!root.hasData) return Constant.waiting
        if (root._dispTemp >= 50) return Constant.anomaly
        if (root._dispTemp >= 40) return Constant.warning
        return Constant.normal
    }
    readonly property color _pwrStateColor: {
        if (!root.hasData) return Constant.waiting
        if (root._dispPower >= 90) return Constant.anomaly
        if (root._dispPower >= 60) return Constant.warning
        return Constant.sensorPower
    }

    ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 10

        // Health status row
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
                    implicitWidth: 10; implicitHeight: 10; radius: 5
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

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // Sensor values with vertical state bars
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Temperature
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Vertical bar (max 60 C)
                Rectangle {
                    implicitWidth: 8; implicitHeight: 50; radius: 4
                    color: Constant.gaugeBg
                    clip: true
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * Math.min(root._dispTemp / 60.0, 1.0)
                        radius: 4
                        color: root._tempStateColor
                        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        Behavior on color  { ColorAnimation  { duration: 250 } }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "Temperature"; color: Constant.textLabel; font.pixelSize: 15 * root._fs; elide: Text.ElideRight }
                    Text {
                        text: root.hasData ? Constant.formatTemp(root._dispTemp) : "—"
                        color: Constant.sensorTemp
                        font.pixelSize: 19 * root._fs; font.bold: true; elide: Text.ElideRight
                    }
                }
            }

            // Power
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Vertical bar (max 100 W)
                Rectangle {
                    implicitWidth: 8; implicitHeight: 50; radius: 4
                    color: Constant.gaugeBg
                    clip: true
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * Math.min(root._dispPower / 100.0, 1.0)
                        radius: 4
                        color: root._pwrStateColor
                        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        Behavior on color  { ColorAnimation  { duration: 250 } }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "Power"; color: Constant.textLabel; font.pixelSize: 15 * root._fs; elide: Text.ElideRight }
                    Text {
                        text: root.hasData ? Constant.formatPower(root._dispPower) : "—"
                        color: Constant.sensorPower
                        font.pixelSize: 19 * root._fs; font.bold: true; elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
