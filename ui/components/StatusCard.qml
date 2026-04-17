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

    // Font scale: normalized to 450px card width
    readonly property real _fs: Math.max(0.55, Math.min(1.4, root.width / 450))

    // Animated display values
    property real _dispTemp:  0.0
    property real _dispPower: 0.0
    property bool _animEnabled: false

    Behavior on _dispTemp  { enabled: root._animEnabled; NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on _dispPower { enabled: root._animEnabled; NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    onTemperatureChanged: if (root.hasData) _dispTemp  = root.temperature
    onPowerChanged:       if (root.hasData) _dispPower = root.power
    onHasDataChanged: {
        if (root.hasData) {
            _animEnabled = false       // snap on first arrival
            _dispTemp  = root.temperature
            _dispPower = root.power
            _animEnabled = true        // animate subsequent updates
        } else {
            _animEnabled = false
            _dispTemp  = 0
            _dispPower = 0
        }
    }

    radius: 6
    color: Constant.bgDetail

    // Overall health color (based on finalState label)
    readonly property color _statusColor: {
        if (root.controlStatus === "Stopped") return Constant.stopped
        if (root.label === -1) return Constant.waiting
        if (root.label ===  0) return Constant.normal
        if (root.label ===  1) return Constant.warning
        return Constant.anomaly
    }

    // Per-sensor state colors
    // qmllint disable missing-property
    readonly property color _tempStateColor: Constant.tempStateColor(root._dispTemp, root.hasData)
    readonly property color _pwrStateColor:  Constant.pwrStateColor(root._dispPower, root.hasData)
    // qmllint enable missing-property

    ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 10

        // Health status row
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text:             "Health Status"
                    color:            Constant.textLabel
                    font.pixelSize:   16 * root._fs
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Rectangle {
                    implicitWidth: 10; implicitHeight: 10; radius: 5
                    color: root._statusColor
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
                Text {
                    text:             root.controlStatus === "Stopped" ? "Stopped" : root.statusText
                    color:            root._statusColor
                    font.pixelSize:   19 * root._fs
                    font.bold:        true
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Constant.border }

        // Sensor values
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            SensorRow {
                Layout.fillWidth: true
                iconSource: "qrc:/images/temperature_icon.svg"
                label:      "Temperature"
                valueText:  root.hasData ? Constant.formatTemp(root._dispTemp) : "—"
                valueColor: Constant.sensorTemp
                iconColor:  Constant.sensorTemp
                gaugeRatio: Math.min(root._dispTemp / Constant.gaugeTempMax, 1.0)
                gaugeColor: root._tempStateColor
                fs:         root._fs
            }

            SensorRow {
                Layout.fillWidth: true
                iconSource: "qrc:/images/power_icon.svg"
                label:      "Power"
                valueText:  root.hasData ? Constant.formatPower(root._dispPower) : "—"
                valueColor: Constant.sensorPower
                iconColor:  Constant.sensorPower
                gaugeRatio: Math.min(root._dispPower / Constant.gaugePwrMax, 1.0)
                gaugeColor: root._pwrStateColor
                fs:         root._fs
            }
        }
    }
}
