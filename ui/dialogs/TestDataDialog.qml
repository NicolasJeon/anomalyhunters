import QtQuick
import QtQuick.Layouts
import QtFacility

// Separate window for single-sample inference testing

Window {
    id: root

    width:        400
    height:       420
    minimumWidth: 400
    minimumHeight: 420
    title:   "Test Mode"
    color:   Constant.bgWindow
    flags:   Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowSystemMenuHint

    readonly property real tempMin:  0
    readonly property real tempMax:  70
    readonly property real pwrMin:   0
    readonly property real pwrMax:  120

    property real testTemperature: 35.0
    property real testPower:       55.0

    // committed on Test Status click
    property real _committedTemp:  35.0
    property real _committedPower: 55.0

    readonly property bool _hasResult: (EquipmentManager.selectedInference["label"] ?? -1) !== -1

    function _collectSeries() {
        return [{ "temperature": root.testTemperature, "power": root.testPower, "label": -1 }]
    }

    function _runInference() {
        root._committedTemp  = root.testTemperature
        root._committedPower = root.testPower
        EquipmentManager.runTestSeries(EquipmentManager.selectedEquipmentId, root._collectSeries())
    }

    ColumnLayout {
        anchors { fill: parent; margins: 24 }
        spacing: 18

        // Input fields
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Temperature
            ColumnLayout {
                Layout.fillWidth:    true
                Layout.preferredWidth: 0
                spacing: 6

                Text { text: "Temperature (C)"; color: Constant.textLabel; font.pixelSize: 12 }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight:   44
                    color:        Constant.bgPanel
                    border.color: "#2a4a5a"
                    radius:       4
                    TextInput {
                        anchors { fill: parent; margins: 6 }
                        color:               Constant.sensorTemp
                        font.pixelSize:      22
                        font.family:         "Courier New"
                        text:                Math.round(root.testTemperature).toString()
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        onTextEdited: {
                            var v = parseInt(text)
                            if (isNaN(v)) return
                            if (v > root.tempMax) { text = root.tempMax.toString(); v = root.tempMax }
                            if (v < root.tempMin) { text = root.tempMin.toString(); v = root.tempMin }
                            root.testTemperature = v
                        }
                    }
                }

                Text {
                    text: root.tempMin + " – " + root.tempMax + " C"
                    color: Constant.textMuted
                    font.pixelSize: 11
                }
            }

            // Power
            ColumnLayout {
                Layout.fillWidth:    true
                Layout.preferredWidth: 0
                spacing: 6

                Text { text: "Power (W)"; color: Constant.textLabel; font.pixelSize: 12 }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight:   44
                    color:        Constant.bgPanel
                    border.color: "#2a3a5a"
                    radius:       4
                    TextInput {
                        anchors { fill: parent; margins: 6 }
                        color:               Constant.sensorPower
                        font.pixelSize:      22
                        font.family:         "Courier New"
                        text:                Math.round(root.testPower).toString()
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        onTextEdited: {
                            var v = parseInt(text)
                            if (isNaN(v)) return
                            if (v > root.pwrMax) { text = root.pwrMax.toString(); v = root.pwrMax }
                            if (v < root.pwrMin) { text = root.pwrMin.toString(); v = root.pwrMin }
                            root.testPower = v
                        }
                    }
                }

                Text {
                    text: root.pwrMin + " – " + root.pwrMax + " W"
                    color: Constant.textMuted
                    font.pixelSize: 11
                }
            }
        }

        // status card
        StatusCard {
            Layout.fillWidth:       true
            Layout.preferredHeight: 140
            controlStatus: root._hasResult ? "Running" : "Stopped"
            label:       EquipmentManager.selectedInference["label"]      ?? -1
            statusText:  EquipmentManager.selectedInference["statusText"] ?? "—"
            hasData:     root._hasResult
            temperature: root._committedTemp
            power:       root._committedPower
        }

        // action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppButton {
                Layout.fillWidth: true
                label:       "Test Status"
                bgColor:     "#0f2a18"
                hoverColor:  "#1a4a2a"
                textColor:   "#55ee88"
                borderColor: "#338855"
                onClicked:   root._runInference()
            }

            AppButton {
                implicitWidth: 100
                label:       "Close"
                bgColor:     Constant.bgPanel
                hoverColor:  "#1e2035"
                textColor:   Constant.textSecondary
                borderColor: Constant.border
                onClicked:   root.visible = false
            }
        }
    }
}
