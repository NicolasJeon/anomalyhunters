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
    stateLogPanel.logs: EquipmentManager.selectedStateLogs

    // ── header controls ──
    equipmentHeader.onStartRequested: EquipmentManager.startEquipment(root.selectedEquipmentId)
    equipmentHeader.onStopRequested:  EquipmentManager.stopEquipment(root.selectedEquipmentId)
    equipmentHeader.onEditRequested: {
        const d = EquipmentManager.selectedEquipment
        equipmentDialog.open(root.selectedEquipmentId,
                             d["name"] ?? "", d["imageSource"] ?? "",
                             d["ip"] ?? "")
    }
}
