import QtQuick
import QtQuick.Controls
import QtFacility

// Shared log list — used by StateLogPanel (in-memory) and StateLogDialog (DB)
ListView {
    id: root

    property string emptyText:     "No state changes yet"
    property int    selectedIndex: -1
    property var    selectedLog:   null
    property int    fontSize:      0   // 0 = default; positive = add to base sizes

    signal saveRequested(var logData)

    function get(index) {
        return model ? model.get(index) : {}
    }

    // ── model change tracking ─────────────────────────────────────────────────
    Connections {
        target: root.model

        function onRowsInserted(parent, first, last) {
            if (root.selectedIndex >= 0)
                root.selectedIndex += (last - first + 1)
        }

        function onRowsRemoved(parent, first, last) {
            if (root.selectedIndex < 0) return
            const removed = last - first + 1
            if (root.selectedIndex >= first && root.selectedIndex <= last) {
                root.selectedIndex = -1
                root.selectedLog   = null
            } else if (root.selectedIndex > last) {
                root.selectedIndex -= removed
            }
        }

        function onDataChanged(topLeft, bottomRight) {
            if (root.selectedIndex >= topLeft.row && root.selectedIndex <= bottomRight.row)
                root.selectedLog = root.get(root.selectedIndex)
        }

        function onModelReset() {
            root.selectedIndex = -1
            root.selectedLog   = null
        }
    }

    clip:    true
    spacing: 2

    add: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0;  to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { property: "x";       from: 80; to: 0; duration: 280; easing.type: Easing.OutCubic }
        }
    }

    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }

    delegate: StateLogDelegate {
        width:        ListView.view.width
        height:       32 + root.fontSize
        listFontSize: root.fontSize
        isSelected:   root.selectedIndex === index

        onRowClicked: (idx) => {
            root.selectedIndex = idx
            root.selectedLog   = root.get(idx)
        }
        onSaveClicked: (idx) => root.saveRequested(root.get(idx))
    }
}
