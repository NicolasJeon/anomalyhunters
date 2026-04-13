import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// 상태 로그 목록 공통 컴포넌트
// StateLogPanel(인메모리)과 StateLogDialog(DB) 양쪽에서 재사용
//
// logs 항목 공통 필드:
//   timestampMs, event, healthStatus, controlStatus, temperature, power
// 인메모리 전용 필드 (없으면 무시):
//   prevHealthStatus, prevTemperature, prevPower, savedToDB
// DB 전용 필드:
//   fromDB = true  (있으면 prev 센서값 숨김)
ListView {
    id: root

    property var    logs:         []
    property string emptyText:    "No state changes yet"
    property int    selectedIndex: -1
    property var    selectedLog:   null
    property int    fontSize:      0   // 0 = default; positive = add to base sizes

    // logs 갱신 시 logId로 선택 항목을 추적 — index 변동 & savedToDB 갱신 대응
    property var _trackLogId: undefined

    onLogsChanged: {
        if (_trackLogId === undefined || selectedIndex < 0) return
        for (let i = 0; i < logs.length; i++) {
            if (logs[i]["logId"] === _trackLogId) {
                selectedIndex = i
                selectedLog   = logs[i]   // 최신 데이터(savedToDB 포함)로 갱신
                return
            }
        }
        // 버퍼에서 밀려난 경우 선택 해제
        selectedIndex = -1
        selectedLog   = null
        _trackLogId   = undefined
    }

    clip:    true
    spacing: 2
    model:   root.logs

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }

    // // 빈 상태 안내
    // Text {
    //     anchors.centerIn: parent
    //     visible:          root.logs.length === 0
    //     text:             root.emptyText
    //     color:            "#333355"
    //     font.pixelSize:   11
    // }

    delegate: Rectangle {
        id: row
        required property var modelData
        required property int index

        // ── 상태 해석 ─────────────────────────────────────────────────────
        // in-memory: event + healthStatus  /  DB: state (unified field)
        readonly property bool fromDB: row.modelData["fromDB"] === true
        readonly property string ev:  row.modelData["event"] ?? ""
        readonly property string hs:  fromDB
                                          ? (row.modelData["state"] ?? "")
                                          : (row.modelData["healthStatus"] ?? "")
        readonly property color stateColor: {
            const key = (ev === "start" || ev === "stop") ? ev : hs
            return Constant.healthColor(key)
        }
        readonly property bool isSelected: root.selectedIndex === row.index

        width:  ListView.view.width
        height: 26 + root.fontSize
        radius: 3
        color:  row.isSelected ? Constant.selectionBg : Constant.logRowBg
        border.color: {
            if (row.isSelected)        return Constant.selectionBorder
            if (row.hs === "Abnormal") return Constant.logRowAbnormal
            if (row.hs === "Warning")  return Constant.logRowWarning
            return "#1c2040"
        }
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.selectedIndex = row.index
                root.selectedLog   = row.modelData
                root._trackLogId   = row.modelData["logId"]   // logId 없으면 undefined → 추적 비활성
            }
        }

        RowLayout {
            anchors {
                fill:        parent
                leftMargin:  6
                rightMargin: 6
            }
            spacing: 5

            // ── 이벤트 아이콘 ────────────────────────────────────────────────
            Text {
                text: {
                    const key = (row.ev === "start" || row.ev === "stop") ? row.ev : row.hs.toLowerCase()
                    if (key === "start") return "▶"
                    if (key === "stop")  return "⏹"
                    return "●"
                }
                color:          row.stateColor
                font.pixelSize: 11 + root.fontSize
            }

            // ── 상태 텍스트 ─────────────────────────────────────────────────
            Text {
                text: (row.ev === "start" || row.ev === "stop")
                      ? row.ev.toUpperCase()
                      : row.hs.toUpperCase()
                color:                 row.stateColor
                font.pixelSize:        11 + root.fontSize
                Layout.preferredWidth: 90
            }

            // ── 현재 센서값 (모든 이벤트) ────────────────────────────────────
            Text {
                text:            Constant.formatTemp(row.modelData["temperature"]  ?? 0)
                               + "  " + Constant.formatPower(row.modelData["power"] ?? 0)
                color:           row.stateColor
                font.pixelSize:  10 + root.fontSize
                font.family:     "Courier New"
                Layout.fillWidth: true
            }

            // ── 시각 ─────────────────────────────────────────────────────────
            Text {
                text:                Qt.formatDateTime(
                                         new Date(row.modelData["timestampMs"] ?? 0),
                                         row.fromDB ? "yyyy-MM-dd HH:mm:ss" : "HH:mm:ss")
                color:               Constant.logSubText
                font.pixelSize:      10 + root.fontSize
                horizontalAlignment: Text.AlignRight
                Layout.alignment:    Qt.AlignRight
            }
        }
    }
}
