import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// 상태 변화 로그 패널 (인메모리 실시간 로그)
// logs: QVariantList — { timestampMs, event, healthStatus, controlStatus,
//                        prevTemperature, prevPower, temperature, power, savedToDB }
Rectangle {
    id: root

    property var    logs:          []
    property string equipmentId:   ""
    property string equipmentName: ""
    property real   temperature:   0
    property real   power:         0

    color:        "#0d0f1c"
    radius:       4
    border.color: "#22253a"
    border.width: 1

    onEquipmentIdChanged: {
        logList.selectedIndex = -1
        logList.selectedLog   = null
        logList._trackLogId   = undefined
    }

    // ── DB 로그 팝업 ─────────────────────────────────────────────────────────
    StateLogDialog {
        id: dbDialog
        equipmentId:   root.equipmentId
        equipmentName: root.equipmentName
    }

    // ── 수동 DB 저장 팝업 ────────────────────────────────────────────────────
    ManualSaveDialog {
        id: manualSaveDialog
        equipmentId:   root.equipmentId
        equipmentName: root.equipmentName
        logId:        logList.selectedLog ? (logList.selectedLog["logId"]       ?? 0) : 0
        temperature:  logList.selectedLog ? (logList.selectedLog["temperature"] ?? 0) : 0
        power:        logList.selectedLog ? (logList.selectedLog["power"]       ?? 0) : 0
        healthStatus: {
            if (!logList.selectedLog) return ""
            const ev = logList.selectedLog["event"] ?? ""
            if (ev === "start" || ev === "stop") return ev
            return logList.selectedLog["healthStatus"] ?? ""
        }
    }

    ColumnLayout {
        anchors {
            fill:    parent
            margins: 8
        }
        spacing: 6

        // ── 헤더 ──────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text:           "Runtime State Log"
                color:          Constant.textLabel
                font.pixelSize: 13
            }
            Text {
                text:           "(" + root.logs.length + ")"
                color:          Constant.textMuted
                font.pixelSize: 11
            }

            Item { Layout.fillWidth: true }

            // DB 저장 버튼
            AppButton {
                implicitWidth:  52
                implicitHeight: 18
                label:          "Save to DB"
                fontSize:       10
                readonly property bool canSave:
                    logList.selectedLog !== null &&
                    !(logList.selectedLog["savedToDB"] === true)
                enabled:     canSave
                bgColor:     canSave ? "#1a1a0f" : Constant.bgPanel
                hoverColor:  "#2a2a1a"
                textColor:   canSave ? "#aaaa44" : Constant.textMuted
                borderColor: canSave ? "#666622" : Constant.border
                onClicked:   manualSaveDialog.open()
            }

            // DB 로그 조회 버튼
            AppButton {
                implicitWidth:  46
                implicitHeight: 18
                label:          "View DB"
                fontSize:       10
                bgColor:        Constant.successBg
                hoverColor:     Constant.successBgHov
                textColor:      Constant.successText
                borderColor:    Constant.successBorder
                onClicked:      dbDialog.loadAndOpen()
            }
        }

        // ── 로그 목록 ─────────────────────────────────────────────────────────
        StateLogList {
            id:                logList
            Layout.fillWidth:  true
            Layout.fillHeight: true
            logs:              root.logs
            emptyText:         "No state changes yet"
        }
    }
}
