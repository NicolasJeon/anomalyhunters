import QtQuick

// Detail panel — logic glue

DetailLayoutForm {
    id: root

    // ── bindings ──
    selDev:              EquipmentManager.selectedEquipment
    selInf:              EquipmentManager.selectedInference
    selTS:               EquipmentManager.selectedTimeSeries
    selectedEquipmentId: EquipmentManager.selectedEquipmentId
    // ── state log ──
    stateLogPanel.stateLogModel: EquipmentManager.stateLogsModel

    // ── header controls ──
    detailHeader.onStartRequested: EquipmentManager.startEquipment(root.selectedEquipmentId)
    detailHeader.onStopRequested:  EquipmentManager.stopEquipment(root.selectedEquipmentId)
    detailHeader.onEditRequested: {
        const d = EquipmentManager.selectedEquipment
        equipmentDialog.open(root.selectedEquipmentId,
                             d["name"] ?? "", d["imageSource"] ?? "",
                             d["ip"] ?? "")
    }
}
