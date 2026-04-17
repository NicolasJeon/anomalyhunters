import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// Shared log list — used by StateLogPanel (in-memory) and StateLogDialog (DB)
// Common fields: timestampMs, event, healthStatus, controlStatus, temperature, power
// In-memory only: prevHealthStatus, prevTemperature, prevPower, savedToDB
// DB only: fromDB = true
ListView {
    id: root

    property var    logs:          []
    property string emptyText:     "No state changes yet"
    property int    selectedIndex: -1
    property var    selectedLog:   null
    property int    fontSize:      0   // 0 = default; positive = add to base sizes

    signal saveRequested(var logData)

    // re-track selected item by logId on log list update
    property var _trackLogId: undefined

    onLogsChanged: {
        if (_trackLogId === undefined || selectedIndex < 0) return
        for (let i = 0; i < logs.length; i++) {
            if (logs[i]["logId"] === _trackLogId) {
                selectedIndex = i
                selectedLog   = logs[i]   // refresh with latest data
                return
            }
        }
        // evicted from buffer — clear selection
        selectedIndex = -1
        selectedLog   = null
        _trackLogId   = undefined
    }

    clip:    true
    spacing: 2
    model:   root.logs

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
    }

    delegate: Rectangle {
        id: row
        required property var modelData
        required property int index

        // ── state ─────────────────────────────────────────────────────────────
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

        readonly property bool canSave: !row.fromDB && !(row.modelData["savedToDB"] === true)

        width:  ListView.view.width
        height: 32 + root.fontSize
        radius: 3
        color:  row.isSelected ? Constant.logRowSelected : Constant.logRowBg

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color:  Constant.logRowBorder
        }
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            color:  Constant.logRowBorder
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.selectedIndex = row.index
                root.selectedLog   = row.modelData
                root._trackLogId   = row.modelData["logId"]   // undefined if no logId → tracking disabled
            }
        }

        RowLayout {
            anchors {
                fill:        parent
                leftMargin:  6
                rightMargin: 15
            }
            spacing: 5

            // ── state text ────────────────────────────────────────────────────
            Text {
                text: (row.ev === "start" || row.ev === "stop")
                      ? row.ev.toUpperCase()
                      : row.hs.toUpperCase()
                color:                 row.stateColor
                font.pixelSize:        12 + root.fontSize
                Layout.preferredWidth: 90
            }

            // ── sensor values ─────────────────────────────────────────────────
            Text {
                text:             Constant.formatTemp(row.modelData["temperature"]  ?? 0)
                                + "  " + Constant.formatPower(row.modelData["power"] ?? 0)
                color:            Constant.logSensorText
                font.pixelSize:   11 + root.fontSize
                font.family:      "Courier New"
                Layout.fillWidth: true
            }

            // ── timestamp ─────────────────────────────────────────────────────
            Text {
                text:                Qt.formatDateTime(
                                         new Date(row.modelData["timestampMs"] ?? 0),
                                         row.fromDB ? "yyyy-MM-dd HH:mm:ss" : "HH:mm:ss")
                color:               Constant.logSubText
                font.pixelSize:      10 + root.fontSize
                horizontalAlignment: Text.AlignRight
                Layout.alignment:    Qt.AlignRight
            }

            // ── save button ───────────────────────────────────────────────────
            AppButton {
                visible:        !row.fromDB
                enabled:        row.canSave
                implicitWidth:  52
                implicitHeight: 20
                label:          row.canSave ? "Save" : "Saved"
                fontSize:       10
                bgColor:        Constant.bgDialog
                hoverColor:     Constant.bgDialog
                textColor:      row.canSave ? Constant.primary.bg  : Constant.textMuted
                borderColor:    row.canSave ? Constant.primary.bg  : Constant.border
                onClicked:      root.saveRequested(row.modelData)
            }
        }
    }
}
