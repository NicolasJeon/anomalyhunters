import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtFacility

// DB 상태 이벤트 로그 팝업
// 사용 예)
//   StateLogDialog { id: dlg; equipmentId: "..."; equipmentName: "Pump A" }
//   dlg.loadAndOpen()
Popup {
    id: root

    property string equipmentId:   ""
    property string equipmentName: ""
    property var    dbLogs:        []

    // DB를 조회한 뒤 팝업을 엽니다.
    function loadAndOpen() {
        dbLogs = equipmentManager.queryEquipmentStateLogs(equipmentId) // qmllint disable unqualified
        open()
    }

    // ── DB 클리어 확인 팝업 ──────────────────────────────────────────────────
    Popup {
        id: clearConfirmDialog
        modal:            true
        anchors.centerIn: Overlay.overlay
        width:            280
        height:           140
        padding:          0

        background: Rectangle {
            color:        Constant.bgDialog
            radius:       8
            border.color: Constant.dangerBorder
            border.width: 1
        }

        ColumnLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 12

            Text {
                text:           "Clear DB"
                color:          Constant.dangerText
                font.pixelSize: 13
                font.bold:      true
            }
            Text {
                text:           "Delete all DB records for " + root.equipmentName + "."
                color:          Constant.textMuted
                font.pixelSize: 11
                wrapMode:       Text.WordWrap
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                AppButton {
                    Layout.fillWidth:  true
                    implicitHeight:    28
                    label:             "Delete"
                    fontSize:          11
                    bold:              true
                    bgColor:           Constant.dangerBg
                    hoverColor:        Constant.dangerBgHov
                    textColor:         Constant.dangerText
                    borderColor:       Constant.dangerBorder
                    onClicked: {
                        equipmentManager.clearEquipmentStateLogs(root.equipmentId) // qmllint disable unqualified
                        root.dbLogs = []
                        clearConfirmDialog.close()
                        toast.show()
                    }
                }
                AppButton {
                    Layout.fillWidth:  true
                    implicitHeight:    28
                    label:             "Cancel"
                    fontSize:          11
                    bgColor:           "#1a1a2e"
                    hoverColor:        "#2a1a2e"
                    textColor:         Constant.textLabel
                    borderColor:       Constant.border
                    onClicked:         clearConfirmDialog.close()
                }
            }
        }
    }

    // ── 완료 토스트 ───────────────────────────────────────────────────────────
    Rectangle {
        id:     toast
        parent: Overlay.overlay

        x:      parent ? (parent.width  - width)  / 2 : 0
        y:      parent ? (parent.height - height) - 24 : 0
        width:        160
        height:       30
        radius:       6
        color:        Constant.successBg
        border.color: Constant.successBorder
        border.width: 1
        opacity:      0
        visible:      opacity > 0

        Text {
            anchors.centerIn: parent
            text:             "DB cleared"
            color:            Constant.successText
            font.pixelSize:   11
        }

        function show() {
            opacity = 1
            hideAnim.restart()
        }

        NumberAnimation {
            id:       hideAnim
            target:   toast
            property: "opacity"
            from:     1; to: 0
            duration: 1500
            easing.type: Easing.InQuad
        }
    }

    // ── 팝업 위치·크기 ────────────────────────────────────────────────────────
    modal:            true
    anchors.centerIn: Overlay.overlay
    width:            620
    height:           460
    padding:          0

    background: Rectangle {
        color:        Constant.bgDialog
        radius:       8
        border.color: Constant.border
        border.width: 1
    }

    // ── 내용 ──────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors {
            fill:    parent
            margins: 14
        }
        spacing: 8

        // ── 헤더 행 ────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text:           "DB View"
                color:          Constant.textLabel
                font.pixelSize: 16
                font.bold:      true
            }
            Text {
                text:           "— " + root.equipmentName
                color:          Constant.textMuted
                font.pixelSize: 15
            }
            Text {
                text:           "(" + root.dbLogs.length + " records)"
                color:          Constant.textMuted
                font.pixelSize: 13
            }

            Item { Layout.fillWidth: true }

            AppButton {
                implicitWidth:  60
                implicitHeight: 22
                label:          "Clear DB"
                fontSize:       11
                bgColor:        Constant.dangerBg
                hoverColor:     Constant.dangerBgHov
                textColor:      Constant.dangerText
                borderColor:    Constant.dangerBorder
                onClicked:      clearConfirmDialog.open()
            }

            AppButton {
                implicitWidth:  60
                implicitHeight: 22
                label:          "✕  Close"
                fontSize:       11
                bgColor:        "#1a1a2e"
                hoverColor:     "#2a1a2e"
                textColor:      Constant.textLabel
                borderColor:    Constant.border
                onClicked:      root.close()
            }
        }

        // ── 구분선 ──────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   1
            color:            Constant.border
        }

        // ── 로그 목록 (StateLogList 재사용) ──────────────────────────────────────
        StateLogList {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            logs:              root.dbLogs
            emptyText:         "No records saved to DB yet"
            fontSize:          2
        }
    }
}
