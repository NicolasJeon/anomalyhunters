import QtQuick
import QtQuick.Layouts

// repository 는 main.cpp 에서 setContextProperty("repository", ...) 로 주입됨
// qmllint disable unqualified

Window {
    id: root
    width: 840
    height: 640
    visible: true
    title: "Equipment Monitor"
    color: "#12141f"

    // ── QML 유틸 함수 ─────────────────────────────────────────────────────
    function healthColor(status) {
        if (status === "anomaly") return "#cc3344"
        if (status === "warning") return "#e8a030"
        if (status === "normal")  return "#22aa66"
        return "#555577"
    }

    function inferenceColor(label) {
        if (label === -1) return "#444466"
        if (label ===  0) return "#1a7a4a"
        return "#9b2335"
    }

    // 장비 추가 시 QML 측 카운터 (초기 3개는 C++에서 생성됨)
    property int addCount: 4

    // 선택된 장비 / 추론 상태 alias
    property var selDev: repository.selectedDevice
    property var selInf: repository.selectedInference

    // ── 메인 레이아웃: 좌(디바이스 목록) + 우(상세) ──────────────────────
    Row {
        anchors.fill: parent

        // ════════════════════════════════════════════════════════════════════
        // 좌측 패널 — 디바이스 목록
        // ════════════════════════════════════════════════════════════════════
        Rectangle {
            id: leftPanel
            width: 220
            height: parent.height
            color: "#0e1020"

            Column {
                anchors.fill: parent

                // ── 헤더 ──────────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 46
                    color: "#181a2e"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        spacing: 8

                        Text {
                            text: "Devices"
                            color: "#c0c0e0"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        // [+] 추가 버튼
                        Rectangle {
                            width: 26; height: 22; radius: 4
                            color: addMouse.containsMouse ? "#2a4a2a" : "#1a3a1a"

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: "#66dd66"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            MouseArea {
                                id: addMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    repository.addDevice(
                                        "Device " + root.addCount,
                                        "Generic", "")
                                    root.addCount++
                                }
                            }
                        }
                    }
                }

                // ── 디바이스 목록 ─────────────────────────────────────────
                ListView {
                    id: deviceList
                    width: parent.width
                    height: parent.height - 46
                    clip: true
                    model: repository.devices

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: deviceList.width
                        height: 66
                        color: modelData["id"] === repository.selectedDeviceId
                               ? "#1e2a46" : "#0e1020"

                        // 선택 표시 바
                        Rectangle {
                            width: 3; height: parent.height
                            color: modelData["id"] === repository.selectedDeviceId
                                   ? "#5599ff" : "transparent"
                        }

                        // 구분선
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 1
                            color: "#1e2035"
                        }

                        // 클릭 → 선택
                        MouseArea {
                            anchors.fill: parent
                            onClicked: repository.selectedDeviceId = modelData["id"]
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            spacing: 8

                            // 상태 원
                            Rectangle {
                                width: 10; height: 10; radius: 5
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.healthColor(modelData["healthStatus"])
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: modelData["name"]
                                    color: "#d0d0ee"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Text {
                                    text: modelData["type"] + "  ·  "
                                          + modelData["healthStatus"]
                                    color: "#666688"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        // 우측 버튼 그룹
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            // Start / Stop
                            Rectangle {
                                width: 44; height: 22; radius: 3
                                color: modelData["controlStatus"] === "running"
                                       ? "#4a1a1a" : "#1a3a1a"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData["controlStatus"] === "running"
                                          ? "Stop" : "Start"
                                    color: modelData["controlStatus"] === "running"
                                           ? "#ff6666" : "#66dd66"
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (modelData["controlStatus"] === "running")
                                            repository.stopDevice(modelData["id"])
                                        else
                                            repository.startDevice(modelData["id"])
                                    }
                                }
                            }

                            // 삭제 [×]
                            Rectangle {
                                width: 22; height: 22; radius: 3
                                color: delMouse.containsMouse ? "#3a1a1a" : "#1e1e2e"

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: "#aa4444"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: delMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: repository.removeDevice(modelData["id"])
                                }
                            }
                        }
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // 우측 패널 — 선택 장비 상세
        // ════════════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width - leftPanel.width
            height: parent.height
            color: "#12141f"

            // ── 미선택 상태 ────────────────────────────────────────────────
            Text {
                anchors.centerIn: parent
                text: "← Select a device"
                color: "#444466"
                font.pixelSize: 18
                visible: repository.selectedDeviceId === ""
            }

            // ── 상세 뷰 ───────────────────────────────────────────────────
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                visible: repository.selectedDeviceId !== ""

                // ── 헤더 (이름 + 타입 + Start/Stop) ──────────────────────
                Row {
                    width: parent.width
                    spacing: 10

                    Column {
                        spacing: 2
                        Text {
                            text: root.selDev["name"] ?? ""
                            color: "#e0e0f8"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text {
                            text: root.selDev["type"] ?? ""
                            color: "#666688"
                            font.pixelSize: 12
                        }
                    }

                    Item { width: 1 }

                    // Start / Stop 버튼 (상세 패널)
                    Rectangle {
                        width: 80; height: 30; radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.selDev["controlStatus"] === "running"
                               ? "#5a1a1a" : "#1a4a1a"

                        Text {
                            anchors.centerIn: parent
                            text: root.selDev["controlStatus"] === "running"
                                  ? "⏹  Stop" : "▶  Start"
                            color: root.selDev["controlStatus"] === "running"
                                   ? "#ff7777" : "#77ff77"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.selDev["controlStatus"] === "running")
                                    repository.stopDevice(repository.selectedDeviceId)
                                else
                                    repository.startDevice(repository.selectedDeviceId)
                            }
                        }
                    }
                }

                // ── 상태 배너 ─────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 6
                    color: root.inferenceColor(root.selInf["label"] ?? -1)

                    Behavior on color { ColorAnimation { duration: 250 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.selInf["statusText"] ?? "—"
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                // ── 현재 값 그리드 ────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 90
                    radius: 6
                    color: "#181a2e"

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        columns: 4
                        rowSpacing: 6
                        columnSpacing: 20

                        Text { text: "Temperature"; color: "#7777aa"; font.pixelSize: 12 }
                        Text { text: "Power";        color: "#7777aa"; font.pixelSize: 12 }
                        Text { text: "P(Normal)";    color: "#7777aa"; font.pixelSize: 12 }
                        Text { text: "P(Abnormal)";  color: "#7777aa"; font.pixelSize: 12 }

                        Text {
                            text: {
                                var ts = repository.selectedTimeSeries
                                return ts.length > 0
                                    ? ts[ts.length-1]["temperature"].toFixed(1) + " °C"
                                    : "—"
                            }
                            color: "#66ffaa"; font.pixelSize: 16; font.bold: true
                        }
                        Text {
                            text: {
                                var ts = repository.selectedTimeSeries
                                return ts.length > 0
                                    ? ts[ts.length-1]["power"].toFixed(1) + " W"
                                    : "—"
                            }
                            color: "#66aaff"; font.pixelSize: 16; font.bold: true
                        }
                        Text {
                            text: root.selInf["label"] === -1 ? "—"
                                : ((root.selInf["probNormal"]   ?? 0) * 100).toFixed(1) + " %"
                            color: "#aaddff"; font.pixelSize: 14
                        }
                        Text {
                            text: root.selInf["label"] === -1 ? "—"
                                : ((root.selInf["probAbnormal"] ?? 0) * 100).toFixed(1) + " %"
                            color: "#ffbb66"; font.pixelSize: 14
                        }
                    }
                }

                // ── P(Abnormal) 게이지 ────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 4

                    Text { text: "Anomaly Probability"; color: "#7777aa"; font.pixelSize: 11 }

                    Rectangle {
                        width: parent.width; height: 14; radius: 3
                        color: "#181a2e"

                        Rectangle {
                            width: parent.width * (root.selInf["probAbnormal"] ?? 0)
                            height: parent.height; radius: 3
                            color: {
                                var p = root.selInf["probAbnormal"] ?? 0
                                if (p < 0.4) return "#1a7a4a"
                                if (p < 0.7) return "#c87941"
                                return "#9b2335"
                            }
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }

                // ── 히스토리 차트 ─────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "History  (" + repository.selectedTimeSeries.length + " samples)"
                        color: "#7777aa"; font.pixelSize: 11
                    }

                    // Temperature bars
                    Text { text: "Temperature  28 – 70 °C"; color: "#555577"; font.pixelSize: 10 }
                    Row {
                        spacing: 2
                        Repeater {
                            model: repository.selectedTimeSeries
                            delegate: Rectangle {
                                required property var modelData
                                property real t: modelData["temperature"] ?? 28
                                width:  Math.floor((840 - 220 - 32) / 20) - 2
                                height: Math.max(2, ((t - 28) / 42) * 50)
                                anchors.bottom: parent ? parent.bottom : undefined
                                radius: 2
                                color:  modelData["label"] === 0 ? "#1a9a5a"
                                      : modelData["label"] === 1 ? "#cc3344"
                                      : "#444466"
                            }
                        }
                    }

                    // Power bars
                    Text { text: "Power  40 – 130 W"; color: "#555577"; font.pixelSize: 10 }
                    Row {
                        spacing: 2
                        Repeater {
                            model: repository.selectedTimeSeries
                            delegate: Rectangle {
                                required property var modelData
                                property real pw: modelData["power"] ?? 40
                                width:  Math.floor((840 - 220 - 32) / 20) - 2
                                height: Math.max(2, ((pw - 40) / 90) * 50)
                                anchors.bottom: parent ? parent.bottom : undefined
                                radius: 2
                                color:  modelData["label"] === 0 ? "#2255cc"
                                      : modelData["label"] === 1 ? "#cc3344"
                                      : "#444466"
                            }
                        }
                    }
                }

                // ── 로그 리스트 ───────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 2

                    Text { text: "Log  (latest → oldest)"; color: "#7777aa"; font.pixelSize: 11 }

                    ListView {
                        width: parent.width
                        height: 104
                        clip: true
                        model: repository.selectedTimeSeries
                        verticalLayoutDirection: ListView.BottomToTop

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            width:  ListView.view.width
                            height: 20
                            color:  index % 2 === 0 ? "#0d0f1e" : "#111324"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 8
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
            }
        }
    }
}
