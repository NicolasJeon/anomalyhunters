import QtQuick

// App layout — logic glue
// qmllint disable unqualified
AppLayoutForm {
    equipmentDialog.onConfirmed: (id, name, img, ip) => {
        if (id === "")
            equipmentManager.addEquipment(name, img, ip)
        else
            equipmentManager.updateEquipment(id, name, img, ip)
    }

    testModeBtn.enabled: {
        const eq = equipmentManager.equipment
        for (var i = 0; i < eq.length; i++)
            if ((eq[i]["controlStatus"] ?? "Stopped") === "Running") return false
        return true
    }

    // qmllint disable missing-property
    testModeBtn.onClicked: {
        testDialog.visible = true
        testDialog.raise()
        testDialog.requestActivate()
    }
    // qmllint enable missing-property
}
