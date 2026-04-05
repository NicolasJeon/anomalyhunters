pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

// Test with Data — 가로 레이아웃
// 각 샘플이 세로 컬럼(temp 바+입력 / power 바+입력)으로 좌→우 나열
// 입력할 때마다 previewChanged 시그널로 HistoryChart 실시간 갱신
ColumnLayout {
    id: root

    readonly property int seqLen: 10
    property string deviceId: ""

    // 입력 변경 시 DetailPanel → HistoryChart 실시간 갱신용
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
        Text { text: "Test with Data"; color: "#7777aa"; font.pixelSize: 11 }
        Item { Layout.fillWidth: true }
        Text {
            text: rowModel.count + " / " + root.seqLen
            color: rowModel.count >= root.seqLen ? "#55ee88" : "#888899"
            font.pixelSize: 10
        }
    }

    // ── 가로 스크롤 입력 + 바 시각화 ─────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6

        // 라벨 컬럼 (고정)
        Column {
            spacing: 0
            // temp 바 영역 높이
            Item    { width: 1; height: 40 }
            // temp 입력 높이
            Text    { text: "Temp"; width: 40; height: 26; color: "#555577"; font.pixelSize: 9;
                      verticalAlignment: Text.AlignVCenter }
            // power 바 영역 높이
            Item    { width: 1; height: 40 }
            // power 입력 높이
            Text    { text: "Power"; width: 40; height: 26; color: "#555577"; font.pixelSize: 9;
                      verticalAlignment: Text.AlignVCenter }
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
                required property int   index
                required property real  temperature
                required property real  power

                spacing: 0
                width: 56

                readonly property real tempNorm:  Math.max(0, Math.min(1, (sampleCol.temperature - 28) / 42))
                readonly property real powerNorm: Math.max(0, Math.min(1, (sampleCol.power - 40) / 90))

                // ── 인덱스 ──────────────────────────────────────────────────
                Text {
                    width: parent.width; height: 12
                    text: sampleCol.index + 1
                    color: "#444466"; font.pixelSize: 8
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── Temp 바 ──────────────────────────────────────────────────
                Item {
                    width: parent.width; height: 40
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - 2; x: 1
                        height: Math.max(2, sampleCol.tempNorm * 40)
                        radius: 2; color: "#1a6677"
                    }
                }

                // ── Temp 입력 ────────────────────────────────────────────────
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
                            rowModel.setProperty(sampleCol.index, "temperature", parseFloat(text) || 0)
                            root.notifyPreview()
                        }
                    }
                }

                // ── Power 바 ──────────────────────────────────────────────────
                Item {
                    width: parent.width; height: 40
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - 2; x: 1
                        height: Math.max(2, sampleCol.powerNorm * 40)
                        radius: 2; color: "#1a3a77"
                    }
                }

                // ── Power 입력 ───────────────────────────────────────────────
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
                            rowModel.setProperty(sampleCol.index, "power", parseFloat(text) || 0)
                            root.notifyPreview()
                        }
                    }
                }

                // ── 삭제 ─────────────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 16; radius: 2
                    color: delMouse.containsMouse ? "#5a1a1a" : "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: "#aa5555"; font.pixelSize: 9 }
                    MouseArea {
                        id: delMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            rowModel.remove(sampleCol.index)
                            root.notifyPreview()
                        }
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
                    rowModel.append({ "temperature": 70.0, "power": 200.0 })
                    listView.positionViewAtEnd()
                    root.notifyPreview()
                }
            }
        }
    }

    // ── Run 버튼 ─────────────────────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true; implicitHeight: 28; radius: 4
        enabled: rowModel.count > 0
        opacity: enabled ? 1.0 : 0.4
        color: runMouse.containsMouse && enabled ? "#1a4a2a" : "#0f2a18"
        border.color: "#338855"; border.width: 1

        Text {
            anchors.centerIn: parent
            text: rowModel.count >= root.seqLen
                  ? "▶  Run Inference  (" + rowModel.count + " samples)"
                  : "▶  Run  (" + rowModel.count + " / " + root.seqLen + " — Collecting data)"
            color: "#55ee88"; font.pixelSize: 11
        }

        MouseArea {
            id: runMouse; anchors.fill: parent; hoverEnabled: true
            onClicked: repository.runTestSeries(root.deviceId, root.collectSeries()) // qmllint disable unqualified
        }
    }
}
