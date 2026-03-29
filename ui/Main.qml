import QtQuick
import QtQuick.Controls
import "components"
import "layout"

// repository 는 main.cpp 에서 setContextProperty("repository", ...) 로 주입됨
// qmllint disable unqualified

Window {
    id: root
    width: 1080
    height: 640
    minimumWidth: 1080
    minimumHeight: 640
    visible: true
    title: "Equipment Monitor"
    color: "#12141f"

    // ── 장비 추가 다이얼로그 ──────────────────────────────────────────────
    AddDeviceDialog {
        id: addDialog
        anchors.fill: parent
        z: 100
        onDeviceAdded: (name, type, img) => repository.addDevice(name, type, img)
    }

    // ── 장비 수정 다이얼로그 ──────────────────────────────────────────────
    EditDeviceDialog {
        id: editDialog
        anchors.fill: parent
        z: 100
        onDeviceUpdated: (id, name, type, img) => repository.updateDevice(id, name, type, img)
    }

    // ── 메인 레이아웃 (SplitView) ─────────────────────────────────────────
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Rectangle {
            implicitWidth: 4
            color: SplitHandle.pressed ? "#5599ff"
                 : SplitHandle.hovered ? "#2a3a5a"
                 : "#1a1c2e"

            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 32; radius: 1
                color: SplitHandle.hovered ? "#5599ff" : "#3a4a6a"
            }
        }

        MasterPanel {
            SplitView.preferredWidth: 260
            SplitView.minimumWidth:   200
            SplitView.maximumWidth:   420
            devices:          repository.devices
            selectedDeviceId: repository.selectedDeviceId
            onDeviceSelected:     (id) => repository.selectedDeviceId = id
            onStartRequested:     (id) => repository.startDevice(id)
            onStopRequested:      (id) => repository.stopDevice(id)
            onEmergencyRequested: (id) => repository.emergencyStop(id)
            onResetRequested:     (id) => repository.resetDevice(id)
            onDeleteRequested:    (id) => repository.removeDevice(id)
            onAddRequested:           addDialog.open()
            onStartAllRequested:      repository.startAll()
            onStopAllRequested:       repository.stopAll()
            onEmergencyAllRequested:  repository.emergencyStopAll()
        }

        DetailPanel {
            SplitView.fillWidth: true
            selDev:           repository.selectedDevice
            selInf:           repository.selectedInference
            selTS:            repository.selectedTimeSeries
            selectedDeviceId: repository.selectedDeviceId
            onStartRequested:     repository.startDevice(repository.selectedDeviceId)
            onStopRequested:      repository.stopDevice(repository.selectedDeviceId)
            onEmergencyRequested: repository.emergencyStop(repository.selectedDeviceId)
            onResetRequested:     repository.resetDevice(repository.selectedDeviceId)
            onEditRequested: {
                var d = repository.selectedDevice
                editDialog.open(repository.selectedDeviceId,  // qmllint disable missing-property
                                d["name"] ?? "", d["type"] ?? "", d["imageSource"] ?? "")
            }
        }
    }
}
