import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    height: 64
    color:  Constant.bgPanel

    RowLayout {
        anchors.fill:    parent
        anchors.margins: 12
        spacing:         10

        Rectangle {
            width: 36; height: 36; radius: 4
            color: Constant.bgThumb

            Text {
                anchors.centerIn: parent
                text:           "⚙"
                font.pixelSize: 20
                color:          Constant.textSecondary
            }
        }

        // ── Practice #4: Delegate 데이터 바인딩 ──────────────────────────────
        // Mission: model 데이터를 각 항목에 연결하세요
        // Hints:   ListView는 delegate마다 model을 자동으로 주입합니다
        //          model.name / model.ip → 아래 Text에 연결하세요
        //          model.running → ControlSwitch의 isRunning에 연결하세요
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                id:             nameText
                text:           "" // TODO: model.name
                color:          Constant.textPrimary
                font.pixelSize: 13
                font.bold:      true
            }

            Text {
                id:             ipText
                text:           "" // TODO: model.ip
                color:          Constant.textSecondary
                font.pixelSize: 11
            }
        }
        ControlSwitch {
            isRunning: false // TODO: model.running
        }

        Text {
            text:           "✕"
            color:          Constant.textMuted
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    {} // step3에서 구현
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width:  parent.width
        height: 1
        color:  Constant.divider
    }
}
