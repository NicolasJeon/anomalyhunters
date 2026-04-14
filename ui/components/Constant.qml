pragma Singleton
import QtQuick

QtObject {

    // Background
    readonly property color bgWindow: "#12141f"
    readonly property color bgPanel:  "#0e1020"
    readonly property color bgCard:   "#181a2e"

    // Border
    readonly property color border: "#2a2c4e"

    // Text
    readonly property color textPrimary:   "#e0e0f8"
    readonly property color textSecondary: "#666688"
    readonly property color textLabel:     "#7777aa"
    readonly property color textMuted:     "#444466"

    // Health state
    readonly property color normal:    "#44cc77"
    readonly property color warning:   "#d89050"
    readonly property color anomaly:   "#cc3344"
    readonly property color waiting:   "#4488cc"
    readonly property color stopped:   "#8899aa"

    // Sensor value text
    readonly property color sensorTemp:  "#66ddaa"
    readonly property color sensorPower: "#66aaff"

    // Chart
    readonly property color chartSlotBg: "#1a1c2e"
    readonly property color gaugeBg:     "#0e1020"

    // Selection / focus
    readonly property color selectionBg:     "#1e2a46"
    readonly property color selectionBorder: "#4466cc"
    readonly property color focusAccent:     "#5599ff"

    // Log rows
    readonly property color logRowBg:       "#13152a"
    readonly property color logRowAbnormal: "#441520"
    readonly property color logRowWarning:  "#3d2810"
    readonly property color logSubText:     "#aabbcc"

    // Dialog
    readonly property color bgDialog: "#0d0f1c"

    // Success action (save, confirm)
    readonly property color successText:   "#44aa66"
    readonly property color successBg:     "#0f2a1c"
    readonly property color successBgHov:  "#1a3a28"
    readonly property color successBorder: "#226644"

    // Danger action (delete, clear)
    readonly property color dangerText:   "#cc5555"
    readonly property color dangerBg:     "#2a0f0f"
    readonly property color dangerBgHov:  "#3a1515"
    readonly property color dangerBorder: "#882222"

    // Control buttons: Start / Stop / Delete
    readonly property color ctrlStartBg:     "#1a3a1a"
    readonly property color ctrlStartBgHov:  "#1a5a1a"
    readonly property color ctrlStartText:   "#ffffff"
    readonly property color ctrlStartBorder: "#2a5a2a"

    readonly property color ctrlStopBg:     "#4a1a1a"
    readonly property color ctrlStopBgHov:  "#5a1a1a"
    readonly property color ctrlStopText:   "#ff6666"

    readonly property color ctrlDeleteBg:     "#1e1e2e"
    readonly property color ctrlDeleteBgHov:  "#3a1a1a"
    readonly property color ctrlDeleteText:   "#aa4444"
    readonly property color ctrlDeleteBorder: "#2a2a3e"

    // Test mode badge
    readonly property color testModeBg:     "#2a1040"
    readonly property color testModeBorder: "#aa44ff"
    readonly property color testModeText:   "#cc88ff"

    // Sensor format helpers
    function formatTemp(value)  { return Math.round(value) + " C" }
    function formatPower(value) { return Math.round(value) + " W" }

    // healthStatus / event → color
    // status: "N/A" | "Normal" | "Warning" | "Abnormal" | "start" | "stop"
    function healthColor(status) {
        const s = status.toLowerCase()
        if (s === "abnormal") return anomaly
        if (s === "warning")  return warning
        if (s === "normal")   return normal
        if (s === "n/a")      return stopped
        if (s === "start")    return "#ffffff"
        if (s === "stop")     return stopped
        return textMuted
    }
}
