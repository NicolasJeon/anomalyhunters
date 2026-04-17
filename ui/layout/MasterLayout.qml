import QtQuick

// Master panel — logic glue

MasterLayoutForm {
    // ── status counts ──
    countTotal:    EquipmentManager.countTotal
    countNormal:   EquipmentManager.countNormal
    countWarning:  EquipmentManager.countWarning
    countAbnormal: EquipmentManager.countAbnormal

    // ── header buttons ──
    btnAdd.onClicked:      equipmentDialog.open("", "", "", "")
    btnStartAll.onClicked: EquipmentManager.startAll()
    btnStopAll.onClicked:  EquipmentManager.stopAll()
}
