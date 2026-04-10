import QtQuick
import QtQuick.Layouts

// 장비 이미지 카드 — 이미지 없을 때 플레이스홀더 표시
Rectangle {
    id: root

    property string imageSource: ""

    radius: 8
    color: "#0e1020"
    border.color: "#2a2c4e"
    border.width: 1

    Image {
        anchors {
            fill: parent
            margins: 6
        }
        source: root.imageSource !== "" ? root.imageSource
                                        : "qrc:/qt/qml/QtFacility/images/default.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
