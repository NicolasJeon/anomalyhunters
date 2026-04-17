import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// In-memory runtime state log panel
Rectangle {
    id: root

    property var    stateLogModel: null
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
            if (logList.count === 0) return
            const next = logList.selectedIndex <= 0 ? 0 : logList.selectedIndex - 1
            logList.selectedIndex = next
            logList.selectedLog   = logList.get(next)
            logList.positionViewAtIndex(next, ListView.Contain)
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            if (logList.count === 0) return
            const next = logList.selectedIndex < 0 ? 0
                       : Math.min(logList.selectedIndex + 1, logList.count - 1)
            logList.selectedIndex = next
            logList.selectedLog   = logList.get(next)
            logList.positionViewAtIndex(next, ListView.Contain)
        }
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
                font.bold:      true
                font.pixelSize: 13
            }
            Text {
                text:           "(" + (root.stateLogModel ? root.stateLogModel.count : 0) + ")"
                color:          Constant.textLabel
                font.pixelSize: 11
            }

            Item { Layout.fillWidth: true }

            AppButton {
                implicitWidth:  52
                implicitHeight: 24
                label:          "View DB"
                fontSize:       12
                bgColor:        Constant.primary.bg
                hoverColor:     Constant.primary.bgHov
                textColor:      Constant.primary.text
                borderColor:    Constant.primary.border
                onClicked:      dbDialog.loadAndOpen()
            }
        }

        StateLogList {
            id:                logList
            Layout.fillWidth:  true
            Layout.fillHeight: true
            model:             root.stateLogModel
            emptyText:         "No state changes yet"
            onSaveRequested: (logData) => {
                manualSaveDialog.logId        = logData["logId"]       ?? 0
                manualSaveDialog.temperature  = logData["temperature"] ?? 0
                manualSaveDialog.power        = logData["power"]       ?? 0
                const ev = logData["event"] ?? ""
                manualSaveDialog.healthStatus = (ev === "start" || ev === "stop")
                                               ? ev : (logData["healthStatus"] ?? "")
                manualSaveDialog.open()
            }
        }
    }
}
