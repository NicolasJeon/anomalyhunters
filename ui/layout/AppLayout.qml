import QtQuick

// App layout — logic glue

AppLayoutForm {
    equipmentDialog.onConfirmed: (id, name, img, ip) => {
        if (id === "")
            EquipmentManager.addEquipment(name, img, ip)
        else
            EquipmentManager.updateEquipment(id, name, img, ip)
    }

    testModeBtn.enabled: !EquipmentManager.anyRunning

    // qmllint disable missing-property
    testModeBtn.onClicked: {
        testDialog.visible = true
        testDialog.raise()
        testDialog.requestActivate()
    }
    // qmllint enable missing-property
}
