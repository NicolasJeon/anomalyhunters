import QtQuick
import QtQuick.Layouts

// 장비 이미지 카드 — 이미지 없을 때 타입 이니셜 플레이스홀더 표시
Rectangle {
    id: root

    property string imageSource: ""
    property string deviceType:  ""

    radius: 8
    color: "#0e1020"
    border.color: "#2a2c4e"; border.width: 1

    Image {
        anchors { fill: parent; margins: 6 }
        source: root.imageSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: root.imageSource !== ""
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4
        visible: root.imageSource === ""

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.deviceType !== "" ? root.deviceType.charAt(0).toUpperCase() : "?"
            color: "#3a3c5e"; font.pixelSize: 36; font.bold: true
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "No Image"
            color: "#2a2c4e"; font.pixelSize: 9
        }
    }
}
