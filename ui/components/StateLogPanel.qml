import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// In-memory runtime state log panel
Rectangle {
    id: root

    property var    logs:          []
    property string equipmentId:   ""
    property string equipmentName: ""
    property real   temperature:   0
    property real   power:         0

    color:        Constant.bgDialog
    radius:       4
    border.color: Constant.border
    border.width: 1

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: {
            if (logList.selectedLog !== null && !(logList.selectedLog["savedToDB"] === true))
                manualSaveDialog.open()
        }
    }

    Shortcut {
        sequence: "Up"
        onActivated: {
            if (logList.logs.length === 0) return
            const next = logList.selectedIndex <= 0 ? 0 : logList.selectedIndex - 1
            logList.selectedIndex = next
            logList.selectedLog   = logList.logs[next]
            logList.positionViewAtIndex(next, ListView.Contain)
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            if (logList.logs.length === 0) return
            const next = logList.selectedIndex < 0 ? 0
                       : Math.min(logList.selectedIndex + 1, logList.logs.length - 1)
            logList.selectedIndex = next
            logList.selectedLog   = logList.logs[next]
            logList.positionViewAtIndex(next, ListView.Contain)
        }
    }

    onEquipmentIdChanged: {
        logList.selectedIndex = -1
        logList.selectedLog   = null
        logList._trackLogId   = undefined
    }

    StateLogDialog {
        id: dbDialog
        equipmentId:   root.equipmentId
        equipmentName: root.equipmentName
    }

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
        anchors { fill: parent; margins: 8 }
        spacing: 6

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

            AppButton {
                implicitWidth:  80
                implicitHeight: 24
                label:          "Save to DB"
                fontSize:       12
                readonly property bool canSave:
                    logList.selectedLog !== null &&
                    !(logList.selectedLog["savedToDB"] === true)
                enabled:     canSave
                bgColor:     canSave ? Constant.saveTo.bg     : Constant.bgPanel
                hoverColor:  canSave ? Constant.saveTo.bgHov  : Constant.bgPanel
                textColor:   canSave ? Constant.saveTo.text   : Constant.textMuted
                borderColor: canSave ? Constant.saveTo.border : Constant.border
                onClicked:   manualSaveDialog.open()
            }

            AppButton {
                implicitWidth:  52
                implicitHeight: 24
                label:          "View DB"
                fontSize:       12
                bgColor:        Constant.success.bg
                hoverColor:     Constant.success.bgHov
                textColor:      Constant.success.text
                borderColor:    Constant.success.border
                onClicked:      dbDialog.loadAndOpen()
            }
        }

        StateLogList {
            id:                logList
            Layout.fillWidth:  true
            Layout.fillHeight: true
            logs:              root.logs
            emptyText:         "No state changes yet"
        }
    }
}
