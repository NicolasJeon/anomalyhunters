import QtQuick
import QtQuick.Layouts
import QtFacility

// Single row delegate for StateLogList
Rectangle {
    id: row

    // ── model roles ───────────────────────────────────────────────────────────
    required property int    index
    required property string event
    required property string healthStatus
    required property int    temperature
    required property int    power
    required property var    timestampMs
    required property bool   savedToDB
    required property bool   fromDB

    // ── set by parent ListView ────────────────────────────────────────────────
    property int  listFontSize: 0
    property bool isSelected:   false

    signal rowClicked(int rowIndex)
    signal saveClicked(int rowIndex)

    // ── derived ───────────────────────────────────────────────────────────────
    readonly property string ev: row.event
    readonly property string hs: row.healthStatus
    readonly property color stateColor: {
        const key = (ev === "start" || ev === "stop") ? ev : hs
        return Constant.healthColor(key)
    }
    readonly property bool canSave: !row.fromDB && !row.savedToDB

    radius: 3
    color:  row.isSelected ? Constant.logRowSelected : Constant.logRowBg

    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 1; color: Constant.logRowBorder
    }
    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 1; color: Constant.logRowBorder
    }

    MouseArea {
        anchors.fill: parent
        onClicked: row.rowClicked(row.index)
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 6; rightMargin: 15 }
        spacing: 5

        // ── state ─────────────────────────────────────────────────────────────
        Text {
            text:                  (ev === "start" || ev === "stop")
                                   ? ev.toUpperCase() : hs.toUpperCase()
            color:                 row.stateColor
            font.pixelSize:        12 + row.listFontSize
            Layout.preferredWidth: 90
        }

        // ── sensor values ─────────────────────────────────────────────────────
        Text {
            text:             Constant.formatTemp(row.temperature)
                            + "  " + Constant.formatPower(row.power)
            color:            Constant.logSensorText
            font.pixelSize:   11 + row.listFontSize
            font.family:      "Courier New"
            Layout.fillWidth: true
        }

        // ── timestamp ─────────────────────────────────────────────────────────
        Text {
            text:                Qt.formatDateTime(
                                     new Date(row.timestampMs ?? 0),
                                     row.fromDB ? "yyyy-MM-dd HH:mm:ss" : "HH:mm:ss")
            color:               Constant.logSubText
            font.pixelSize:      10 + row.listFontSize
            horizontalAlignment: Text.AlignRight
            Layout.alignment:    Qt.AlignRight
        }

        // ── save button ───────────────────────────────────────────────────────
        AppButton {
            visible:        !row.fromDB
            enabled:        row.canSave
            implicitWidth:  52
            implicitHeight: 20
            label:          row.canSave ? "Save" : "Saved"
            fontSize:       10
            bgColor:        Constant.bgDialog
            hoverColor:     Constant.bgDialog
            textColor:      row.canSave ? Constant.primary.bg : Constant.textMuted
            borderColor:    row.canSave ? Constant.primary.bg : Constant.border
            onClicked:      row.saveClicked(row.index)
        }
    }
}
