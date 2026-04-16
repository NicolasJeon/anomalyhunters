pragma Singleton
import QtQuick

QtObject {

    // Background
    readonly property color bgWindow: "#12141f"
    readonly property color bgPanel:  "#0e1020"
    readonly property color bgCard:   "#181a2e"
    readonly property color bgDialog: "#0d0f1c"

    // Border
    readonly property color border: "#2a2c4e"

    // Text
    readonly property color textPrimary:   "#e0e0f8"
    readonly property color textSecondary: "#666688"
    readonly property color textLabel:     "#7777aa"
    readonly property color textMuted:     "#444466"

    // Health state
    readonly property color normal:  "#44cc77"
    readonly property color warning: "#d89050"
    readonly property color anomaly: "#cc3344"
    readonly property color waiting: "#4488cc"
    readonly property color stopped: "#8899aa"

    // Sensor
    readonly property color sensorTemp:  "#66ddaa"
    readonly property color sensorPower: "#66aaff"

    // Chart / gauge
    readonly property color chartSlotBg: "#1a1c2e"
    readonly property color gaugeBg:     "#0e1020"
    readonly property real  gaugeTempMax: 60.0
    readonly property real  gaugePwrMax: 100.0

    // Selection / focus
    readonly property color selectionBg:     "#1e2a46"
    readonly property color selectionBorder: "#4466cc"
    readonly property color focusAccent:     "#5599ff"

    // Log rows
    readonly property color logRowBg:       "#13152a"
    readonly property color logRowAbnormal: "#441520"
    readonly property color logRowWarning:  "#3d2810"
    readonly property color logSubText:     "#aabbcc"

    // Input
    readonly property color inputFocusBorder: "#818cf8"

    // Action color groups
    readonly property var success:  ({ text: "#44aa66", bg: "#0f2a1c", bgHov: "#1a3a28", border: "#226644" })
    readonly property var danger:   ({ text: "#cc5555", bg: "#2a0f0f", bgHov: "#3a1515", border: "#882222" })
    readonly property var ctrlStart:({ bg: "#1a3a1a", bgHov: "#1a5a1a", text: "#ffffff", border: "#2a5a2a" })
    readonly property var ctrlStop: ({ bg: "#4a1a1a", bgHov: "#5a1a1a", text: "#ff6666" })
    readonly property var cancel:   ({ bg: "#1a1a2e", bgHov: "#2a1a2e" })
    readonly property var saveTo:   ({ bg: "#1a1a0f", bgHov: "#2a2a1a", text: "#aaaa44", border: "#666622" })

    // Sensor format helpers
    function formatTemp(value)  { return Math.round(value) + " C" }
    function formatPower(value) { return Math.round(value) + " W" }

    // Sensor state color helpers
    function tempStateColor(val, hasData) {
        if (!hasData)  return waiting
        if (val >= 50) return anomaly
        if (val >= 40) return warning
        return normal
    }
    function pwrStateColor(val, hasData) {
        if (!hasData)  return waiting
        if (val >= 90) return anomaly
        if (val >= 60) return warning
        return sensorPower
    }

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
