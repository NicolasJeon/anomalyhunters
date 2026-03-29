import QtQuick
import QtQuick.Layouts

// 히스토리 바 차트 — Temperature / Power (정상: 녹, 경고: 주황, 이상: 적, 버퍼: 회)
ColumnLayout {
    id: root

    property var timeSeries: []

    spacing: 6

    Text {
        text: "History  (" + root.timeSeries.length + " samples)"
        color: "#7777aa"; font.pixelSize: 11
    }

    // Temperature bars
    Text { text: "Temperature  28 – 70 °C"; color: "#555577"; font.pixelSize: 10 }
    RowLayout {
        Layout.fillWidth: true
        spacing: 2
        Repeater {
            model: root.timeSeries
            delegate: Item {
                id: tempBar
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 50

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, ((tempBar.modelData["temperature"] - 28) / 42) * 50)
                    radius: 2
                    color: tempBar.modelData["label"] === 0 ? "#1a9a5a"
                         : tempBar.modelData["label"] === 1 ? "#c87941"
                         : tempBar.modelData["label"] === 2 ? "#cc3344"
                         : "#444466"
                }
            }
        }
    }

    // Power bars
    Text { text: "Power  40 – 130 W"; color: "#555577"; font.pixelSize: 10 }
    RowLayout {
        Layout.fillWidth: true
        spacing: 2
        Repeater {
            model: root.timeSeries
            delegate: Item {
                id: powerBar
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 50

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, ((powerBar.modelData["power"] - 40) / 90) * 50)
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
