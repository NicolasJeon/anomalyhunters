import QtQuick

// Detail panel — logic glue
// qmllint disable unqualified
DetailLayoutForm {
    id: root

    // ── bindings ──
    selDev:              equipmentManager.selectedEquipment
    selInf:              equipmentManager.selectedInference
    selTS:               equipmentManager.selectedTimeSeries
    selectedEquipmentId: equipmentManager.selectedEquipmentId
    // ── state log ──
    stateLogPanel.logs: equipmentManager.selectedStateLogs

    // ── header controls ──
    equipmentHeader.onStartRequested: equipmentManager.startEquipment(root.selectedEquipmentId)
    equipmentHeader.onStopRequested:  equipmentManager.stopEquipment(root.selectedEquipmentId)
    equipmentHeader.onEditRequested: {
        const d = equipmentManager.selectedEquipment
        equipmentDialog.open(root.selectedEquipmentId,
                             d["name"] ?? "", d["imageSource"] ?? "",
                             d["ip"] ?? "")
    }
}
