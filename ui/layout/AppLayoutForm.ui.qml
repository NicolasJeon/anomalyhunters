import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import "../dialogs"

// App layout — structure only
Item {
    id: root

    property alias masterLayout:    masterLayout
    property alias detailLayout:    detailLayout
    property alias equipmentDialog: equipmentDialog
    property alias testModeBtn:     appHeader.testModeBtn
    property alias testDialog:      testDialog

    // ── secondary OS window ───────────────────────────────────────────────────
    // qmllint disable import
    TestDataDialog { id: testDialog }
    // qmllint enable import

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── header ────────────────────────────────────────────────────────────
        HeaderLayout {
            id:               appHeader
            Layout.fillWidth: true
        }

        // ── SplitView ─────────────────────────────────────────────────────────
        SplitView {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            orientation:       Qt.Horizontal

            // ── handle style ──────────────────────────────────────────────────
            handle: Rectangle {
                implicitWidth: 4
                color: SplitHandle.pressed ? Constant.focusAccent
                     : SplitHandle.hovered ? "#2a3a5a"
                     : Constant.bgCard

                Rectangle {
                    anchors.centerIn: parent
                    width:  2
                    height: 32
                    radius: 1
                    color: SplitHandle.hovered ? Constant.focusAccent : "#3a4a6a"
                }
            }

            // ── master (left) ─────────────────────────────────────────────────
            MasterLayout {
                id:                       masterLayout
                SplitView.preferredWidth: 260
                SplitView.minimumWidth:   200
                SplitView.maximumWidth:   420
            }

            // ── detail (right) ────────────────────────────────────────────────
            DetailLayout {
                id:                     detailLayout
                SplitView.fillWidth:    true
                SplitView.minimumWidth: 560
            }
        }
    }

    // ── equipment dialog overlay ──────────────────────────────────────────────
    EquipmentDialog {
        id:           equipmentDialog
        anchors.fill: parent
        z:            100
    }
}
