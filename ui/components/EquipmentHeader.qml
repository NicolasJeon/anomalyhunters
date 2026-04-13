import QtQuick
import QtQuick.Layouts

// 상세 패널 헤더 — 장비 이름 + 상태별 제어 버튼
// controlStatus: "Stopped" | "Running"
RowLayout {
    id: root

    property string name:          ""
    property string controlStatus: "Stopped"

    signal startRequested()
    signal stopRequested()
    signal editRequested()

    spacing: 10

    // 장비 이름
    Text {
        text: root.name
        color: "#e0e0f8"
        font.pixelSize: 18
        font.bold: true
    }

    Item { Layout.fillWidth: true }

    // 편집 버튼 (항상 표시)
    AppButton {
        implicitWidth: 64
        label: "Edit"
        bgColor: "#1a2035"
        hoverColor: "#253050"
        textColor: "#6688bb"
        hoverTextColor: "#88aaff"
        borderColor: "#2a3a5a"
        hoverBorderColor: "#5599ff"
        onClicked: root.editRequested()
    }

    // Stopped → [▶ Start]
    AppButton {
        visible: root.controlStatus === "Stopped"
        implicitWidth: 80
        label: "Start"
        bgColor:    Constant.ctrlStartBg
        hoverColor: Constant.ctrlStartBgHov
        textColor:  Constant.ctrlStartText
        onClicked: root.startRequested()
    }

    // Running → [⏹ Stop]
    AppButton {
        visible: root.controlStatus === "Running"
        implicitWidth: 70
        label: "Stop"
        bgColor:    Constant.ctrlStopBg
        hoverColor: Constant.ctrlStopBgHov
        textColor:  Constant.ctrlStopText
        onClicked: root.stopRequested()
    }
}
