pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

// 히스토리 바 차트 (normal) + Test with Data 입력 (test mode) 통합
ColumnLayout {
    id: root

    property var    timeSeries: []
    property bool   canTest:    false
    property bool   testMode:   false
    property string deviceId:   ""

    readonly property int seqLen: 10

    // 고정 도메인 (라벨과 일치)
    readonly property real _tempMin:   28.0
    readonly property real _tempMax:   70.0
    readonly property real _pwrMin:    40.0
    readonly property real _pwrMax:   130.0

    signal testToggled()
    signal previewChanged(var series)

    function collectSeries() {
        var arr = []
        for (var i = 0; i < rowModel.count; i++) {
            var r = rowModel.get(i)
            arr.push({ "temperature": r.temperature, "power": r.power,
                       "label": -1, "probAbnormal": 0 })
        }
        return arr
    }
    function notifyPreview() { previewChanged(collectSeries()) }

    spacing: 6

    // ── 헤더 ─────────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: root.testMode
                  ? "Test with Data  (" + rowModel.count + " / " + root.seqLen + ")"
                  : "History  (" + root.timeSeries.length + " samples)"
            color: "#7777aa"; font.pixelSize: 11
        }

        Item { Layout.fillWidth: true }

        // Run 버튼 (test mode)
        Rectangle {
            visible: root.testMode
            enabled: rowModel.count > 0
            opacity: enabled ? 1.0 : 0.4
            implicitWidth: 130; implicitHeight: 22; radius: 3
            color: runMouse.containsMouse && enabled ? "#1a4a2a" : "#0f2a18"
            border.color: "#338855"; border.width: 1
            Text {
                anchors.centerIn: parent
                text: rowModel.count >= root.seqLen
                      ? "▶  Run Inference"
                      : "▶  Run  (Collecting…)"
                color: "#55ee88"; font.pixelSize: 10
            }
            MouseArea {
                id: runMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: repository.runTestSeries(root.deviceId, root.collectSeries()) // qmllint disable unqualified
            }
        }

        // Test with Data 토글 버튼
        Rectangle {
            visible: root.canTest
            implicitWidth: 110; implicitHeight: 22; radius: 3
            color: root.testMode ? (testBtnMouse.containsMouse ? "#2a1040" : "#1a0830")
                                 : (testBtnMouse.containsMouse ? "#1a2a1a" : "#111a11")
            border.color: root.testMode ? "#aa44ff" : "#336644"; border.width: 1
            Text {
                anchors.centerIn: parent
                text: root.testMode ? "✕ Close Test" : "⚗ Test with Data"
                color: root.testMode ? "#cc88ff" : "#55bb77"
                font.pixelSize: 10
            }
            MouseArea { id: testBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.testToggled() }
        }
    }

    // ── Normal 모드: 기존 바 차트 ────────────────────────────────────────────
    ColumnLayout {
        visible: !root.testMode
        Layout.fillWidth: true
        spacing: 4

        Text { text: "Temperature  28 – 70 °C"; color: "#555577"; font.pixelSize: 10 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 2
            Repeater {
                model: root.timeSeries
                delegate: Item {
                    id: tempBar
                    required property var modelData
                    Layout.fillWidth: true; implicitHeight: 50
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(2, ((tempBar.modelData["temperature"] - root._tempMin) / (root._tempMax - root._tempMin)) * 50)
                        radius: 2
                        color: tempBar.modelData["label"] === 0 ? "#1a8899"
                             : tempBar.modelData["label"] === 1 ? "#c87941"
                             : tempBar.modelData["label"] === 2 ? "#cc3344"
                             : "#444466"
                    }
                }
            }
        }

        Text { text: "Power  40 – 130 W"; color: "#555577"; font.pixelSize: 10 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 2
            Repeater {
                model: root.timeSeries
                delegate: Item {
                    id: powerBar
                    required property var modelData
                    Layout.fillWidth: true; implicitHeight: 50
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(2, ((powerBar.modelData["power"] - root._pwrMin) / (root._pwrMax - root._pwrMin)) * 50)
                        radius: 2
                        color: powerBar.modelData["label"] === 0 ? "#2255cc"
                             : powerBar.modelData["label"] === 1 ? "#c87941"
                             : powerBar.modelData["label"] === 2 ? "#cc3344"
                             : "#444466"
                    }
                }
            }
        }
    }

    // ── Test 모드: 가로 입력 컬럼 ────────────────────────────────────────────
    RowLayout {
        visible: root.testMode
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6

        // 라벨 컬럼 — 각 라벨이 바(높이 40) 행에 정렬
        Column {
            spacing: 0
            Item    { width: 1; height: 12 }   // index 행
            Text    { text: "Temp";  width: 42; height: 40; color: "#555577"; font.pixelSize: 9; verticalAlignment: Text.AlignVCenter }
            Item    { width: 1; height: 26 }   // temp 입력 행
            Text    { text: "Power"; width: 42; height: 40; color: "#555577"; font.pixelSize: 9; verticalAlignment: Text.AlignVCenter }
            Item    { width: 1; height: 26 }   // power 입력 행
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 4
            clip: true
            model: ListModel { id: rowModel }

            delegate: Column {
                id: sampleCol
                required property int  index
                required property real temperature
                required property real power

                spacing: 0
                width: 56

                readonly property real tempNorm:  Math.min(1, Math.max(0, (sampleCol.temperature - root._tempMin) / (root._tempMax - root._tempMin)))
                readonly property real powerNorm: Math.min(1, Math.max(0, (sampleCol.power      - root._pwrMin) / (root._pwrMax - root._pwrMin)))

                // 인덱스
                Text {
                    width: parent.width; height: 12
                    text: sampleCol.index + 1
                    color: "#444466"; font.pixelSize: 8
                    horizontalAlignment: Text.AlignHCenter
                }
                // Temp 바
                Item {
                    width: parent.width; height: 40
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - 2; x: 1
                        height: Math.max(2, sampleCol.tempNorm * 40)
                        radius: 2; color: "#1a6677"
                    }
                }
                // Temp 입력
                Rectangle {
                    width: parent.width; height: 26
                    color: "#1a1c2e"; border.color: "#2a4a5a"; radius: 3
                    TextInput {
                        anchors { fill: parent; margins: 3 }
                        color: "#44ccee"; font.pixelSize: 10; font.family: "Courier New"
                        text: sampleCol.temperature.toFixed(1)
                        horizontalAlignment: Text.AlignHCenter
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: {
                            var v = Math.min(root._tempMax, Math.max(root._tempMin, parseFloat(text) || root._tempMin))
                            rowModel.setProperty(sampleCol.index, "temperature", v)
                            text = v.toFixed(1)
                            root.notifyPreview()
                        }
                    }
                }
                // Power 바
                Item {
                    width: parent.width; height: 40
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - 2; x: 1
                        height: Math.max(2, sampleCol.powerNorm * 40)
                        radius: 2; color: "#1a3a77"
                    }
                }
                // Power 입력
                Rectangle {
                    width: parent.width; height: 26
                    color: "#1a1c2e"; border.color: "#2a3a5a"; radius: 3
                    TextInput {
                        anchors { fill: parent; margins: 3 }
                        color: "#66aaff"; font.pixelSize: 10; font.family: "Courier New"
                        text: sampleCol.power.toFixed(1)
                        horizontalAlignment: Text.AlignHCenter
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: {
                            var v = Math.min(root._pwrMax, Math.max(root._pwrMin, parseFloat(text) || root._pwrMin))
                            rowModel.setProperty(sampleCol.index, "power", v)
                            text = v.toFixed(1)
                            root.notifyPreview()
                        }
                    }
                }
                // 삭제
                Rectangle {
                    width: parent.width; height: 16; radius: 2
                    color: delMouse.containsMouse ? "#5a1a1a" : "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: "#aa5555"; font.pixelSize: 9 }
                    MouseArea {
                        id: delMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: { rowModel.remove(sampleCol.index); root.notifyPreview() }
                    }
                }
            }
        }

        // + 버튼
        Rectangle {
            implicitWidth: 28; implicitHeight: 28; radius: 4
            color: addMouse.containsMouse ? "#1a2a3a" : "#111928"
            border.color: "#334466"; border.width: 1
            Text { anchors.centerIn: parent; text: "+"; color: "#6688bb"; font.pixelSize: 16 }
            MouseArea {
                id: addMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    rowModel.append({ "temperature": 35.0, "power": 55.0 })
                    listView.positionViewAtEnd()
                    root.notifyPreview()
                }
            }
        }
    }
}
