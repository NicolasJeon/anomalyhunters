import QtQuick
import QtQuick.Layouts
import QtFacility

// Detail panel header — name / edit / toggle
// controlStatus: "Stopped" | "Running"
RowLayout {
    id: root

    property string name:          ""
    property string controlStatus: "Stopped"

    readonly property bool isRunning: controlStatus === "Running"

    signal startRequested()
    signal stopRequested()
    signal editRequested()

    spacing: 10

    // 장비 이름
    Text {
        text: root.name
        color: Constant.textPrimary
        font.pixelSize: 18
        font.bold: true
    }

    // 편집 버튼 (이름 오른쪽)
    AppButton {
        implicitWidth: 64
        label:         "Edit"
        bgColor:       Constant.primary.bg
        hoverColor:    Constant.primary.bgHov
        textColor:     Constant.primary.text
        borderColor:   Constant.primary.border
        onClicked: root.editRequested()
    }

    Item { Layout.fillWidth: true }

    // 토글 스위치
    ControlSwitch {
        Layout.alignment: Qt.AlignVCenter
        isRunning:        root.isRunning
        onStartRequested: root.startRequested()
        onStopRequested:  root.stopRequested()
    }
}
