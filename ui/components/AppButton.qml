import QtQuick

// 공통 버튼 컴포넌트
//
// 사용 예)
//   AppButton {
//       implicitWidth: 80
//       label: "▶ Start"
//       bgColor: "#1a4a1a"; hoverColor: "#1a5a1a"
//       textColor: "#77ff77"
//       onClicked: root.startRequested()
//   }
Rectangle {
    id: root

    // ── 필수 속성 ─────────────────────────────────────────────────────────
    property string label:            ""            // 버튼 텍스트
    property color  bgColor:          "#1a2035"     // 기본 배경색
    property color  hoverColor:       bgColor       // 마우스 오버 시 배경색
    property color  textColor:        "#88aaff"     // 기본 텍스트 색
    property color  hoverTextColor:   textColor     // 마우스 오버 시 텍스트 색
    property color  borderColor:      "transparent" // 테두리 색 (transparent = 테두리 없음)
    property color  hoverBorderColor: borderColor   // 마우스 오버 시 테두리 색
    property int    fontSize:         12            // 폰트 크기
    property bool   bold:             false         // 굵게 여부

    signal clicked()

    // ── 시각 ──────────────────────────────────────────────────────────────
    implicitHeight: 30
    radius: 4
    color:        mouse.containsMouse ? root.hoverColor       : root.bgColor
    border.color: mouse.containsMouse ? root.hoverBorderColor : root.borderColor
    border.width: 1

    Text {
        anchors.centerIn: parent
        text:           root.label
        color:          mouse.containsMouse ? root.hoverTextColor : root.textColor
        font.pixelSize: root.fontSize
        font.bold:      root.bold
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked:    root.clicked()
    }
}
