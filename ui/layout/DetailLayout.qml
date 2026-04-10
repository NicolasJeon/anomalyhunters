import QtQuick

// 우측 DETAIL 레이아웃 — 로직/글루 전용
// qmllint disable unqualified
DetailLayoutForm {
    id: root

    // ── equipmentManager 바인딩 ───────────────────────────────────────────
    selDev:              equipmentManager.selectedEquipment
    selInf:              equipmentManager.selectedInference
    selTS:               equipmentManager.selectedTimeSeries
    selectedEquipmentId: equipmentManager.selectedEquipmentId
    // ── 상태 로그 ─────────────────────────────────────────────────────────
    stateLogPanel.logs: equipmentManager.selectedStateLogs

    // ── 헤더 제어 버튼 ────────────────────────────────────────────────────
    equipmentHeader.onStartRequested: {
        root.testMode = false
        equipmentManager.startEquipment(root.selectedEquipmentId)
    }
    equipmentHeader.onStopRequested: equipmentManager.stopEquipment(root.selectedEquipmentId)
    equipmentHeader.onEditRequested: {
        const d = equipmentManager.selectedEquipment
        equipmentDialog.open(root.selectedEquipmentId,
                             d["name"] ?? "", d["imageSource"] ?? "")
    }

    // ── 히스토리 차트 ─────────────────────────────────────────────────────
    historyChart.onTestToggled: {
        root.testMode = !root.testMode
        if (root.testMode)
            equipmentManager.clearEquipmentDisplay(root.selectedEquipmentId)
        else
            root.testSeries = []
    }
    historyChart.onPreviewChanged: (series) => root.testSeries = series
}
