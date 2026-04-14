import QtQuick
import QtQuick.Layouts
import QtFacility

// Equipment list item: thumbnail / name+status / control buttons
Rectangle {
    id: root

    property var  equipmentData: ({})
    property bool isSelected:    false

    signal selected()
    signal startRequested()
    signal stopRequested()
    signal deleteRequested()

    readonly property string controlStatus: equipmentData["controlStatus"] ?? "Stopped"
    readonly property string healthStatus:  equipmentData["healthStatus"]  ?? "Normal"

    function healthColor(status) { return Constant.healthColor(status) }

    component DeleteBtn: AppButton {
        implicitWidth: 44
        implicitHeight: 18
        label: "Delete"
        fontSize: 10
        bgColor:     Constant.ctrlDeleteBg
        hoverColor:  Constant.ctrlDeleteBgHov
        textColor:   Constant.ctrlDeleteText
        borderColor: Constant.ctrlDeleteBorder
        onClicked: root.deleteRequested()
    }

    height: 76
    color: root.isSelected ? Constant.selectionBg : Constant.bgPanel

    // Selection indicator bar
    Rectangle { width: 3; height: parent.height; color: root.isSelected ? Constant.focusAccent : "transparent" }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#1e2035"
    }

    MouseArea { anchors.fill: parent; onClicked: root.selected() }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 8
            topMargin: 6
            bottomMargin: 6
        }
        spacing: 8

        // Thumbnail: image + bottom-right status dot
        Item {
            implicitWidth: 36
            implicitHeight: 36
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: "#0e1020"
                visible: true

                Image {
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    source: (root.equipmentData["imageSource"] ?? "") !== ""
                            ? root.equipmentData["imageSource"]
                            : "qrc:/qt/qml/QtFacility/images/default.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    width: 8
                    height: 8
                    radius: 4
                    color: root.healthColor(root.healthStatus)
                    border.color: "#0e1020"
                    border.width: 1
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                text: root.equipmentData["name"] ?? ""
                color: "#d0d0ee"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.healthStatus
                color: "#666688"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.controlStatus === "Stopped"
                spacing: 4
                AppButton {
                    implicitWidth: 44
                    implicitHeight: 18
                    label: "Start"
                    fontSize: 10
                    bgColor:    Constant.ctrlStartBg
                    hoverColor: Constant.ctrlStartBgHov
                    textColor:  Constant.ctrlStartText
                    onClicked: root.startRequested()
                }
                Item { Layout.fillWidth: true }
                DeleteBtn {}
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.controlStatus === "Running"
                spacing: 4
                AppButton {
                    implicitWidth: 44
                    implicitHeight: 18
                    label: "Stop"
                    fontSize: 10
                    bgColor:    Constant.ctrlStopBg
                    hoverColor: Constant.ctrlStopBgHov
                    textColor:  Constant.ctrlStopText
                    onClicked: root.stopRequested()
                }
                Item { Layout.fillWidth: true }
                DeleteBtn {}
            }
        }
    }
}
