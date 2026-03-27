import QtQuick
import QtQuick.Layouts

// 추론 로그 리스트 — 최신순 (BottomToTop)
ColumnLayout {
    id: root

    property var timeSeries: []

    spacing: 2

    Text { text: "Log  (latest → oldest)"; color: "#7777aa"; font.pixelSize: 11 }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: root.timeSeries
        verticalLayoutDirection: ListView.BottomToTop

        delegate: Rectangle {
            required property var modelData
            required property int index

            width:  ListView.view.width
            height: 20
            color:  index % 2 === 0 ? "#0d0f1e" : "#111324"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 8
                font.pixelSize: 10
                font.family: "Courier New"
                color: parent.modelData["label"] === 0 ? "#55ee88"
                     : parent.modelData["label"] === 1 ? "#ff6666"
                     : "#666688"
                text: {
                    var d   = parent.modelData
                    var lbl = d["label"] === -1 ? "buf"
                            : d["label"] === 0  ? "OK "
                            : "ERR"
                    var pa  = d["label"] === -1 ? "  —  "
                            : ((d["probAbnormal"] ?? 0) * 100).toFixed(1) + "%"
                    return lbl
                        + "  T:" + (d["temperature"] ?? 0).toFixed(1) + "°"
                        + "  P:" + (d["power"]       ?? 0).toFixed(1) + "W"
                        + "  p_abn:" + pa
                }
            }
        }
    }
}
