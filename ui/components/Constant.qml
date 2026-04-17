pragma Singleton
import QtQuick

QtObject {

    // Background
    readonly property color bgWindow:      "#12141f"
    readonly property color bgPanel:       "#0e1020"
    readonly property color bgCard:        "#181a2e"
    readonly property color bgDialog:      "#2d2d2d"
    readonly property color bgDetail:      "#262626"
    readonly property color bgOverlay:     "#a0000000"
    readonly property color bgThumb:       "#12182e"
    readonly property color bgThumbOff:    "#0c0e18"

    // Border / divider
    readonly property color border:        "#2a2c4e"
    readonly property color divider:       "#1e2035"
    readonly property color dividerDark:   "#1e2040"
    readonly property color inputBorder:   "#2a3a5a"

    // Text
    readonly property color textPrimary:   "#e0e0f8"
    readonly property color textSecondary: "#666688"
    readonly property color textLabel:     "#7777aa"
    readonly property color textMuted:     "#444466"
    readonly property color textHeader:    "#c0c0e0"
    readonly property color textInput:     "#d0d0ee"
    readonly property color textStopped:   "#555570"
    readonly property color textIpOn:      "#55557a"
    readonly property color textIpOff:     "#333350"
    readonly property color white:         "#ffffff"

    // Stats bar
    readonly property color statsDot:      "#333355"

    // Health state
    readonly property color normal:  "#10B981"
    readonly property color warning: "#F59E0B"
    readonly property color anomaly: "#EF4444"
    readonly property color waiting: "#4488cc"
    readonly property color stopped: "#8899aa"

    // Sensor
    readonly property color sensorTemp:  "#51b3f3"
    readonly property color sensorPower: "#9885f4"

    // Chart / gauge
    readonly property color chartSlotBg: "#1a1c2e"
    readonly property color gaugeBg:     "#0e1020"
    readonly property real  gaugeTempMax: 60.0
    readonly property real  gaugePwrMax: 100.0

    // Selection / focus
    readonly property color selectionBg:     "#1e2a46"
    readonly property color selectionBorder: "#4466cc"
    readonly property color focusAccent:     "#5599ff"
    readonly property color inputFocusBorder: "#818cf8"

    // Control switch
    readonly property color switchOffBg:     "#4a4e6a"
    readonly property color switchOffBorder: "#6a6e8a"
    readonly property color switchKnobOff:   "#9a9cb8"

    // Splitter handle
    readonly property color splitterHover: "#2a3a5a"
    readonly property color splitterDot:   "#3a4a6a"

    // Log rows
    readonly property color logRowBg:       "#2d2d2d"
    readonly property color logRowSelected: "#3f3f3f"
    readonly property color logRowAbnormal: "#4a1a1a"
    readonly property color logRowWarning:  "#4a3010"
    readonly property color logSubText:     "#aabbcc"
    readonly property color logSensorText:  "#7c8eb5"
    readonly property color logRowBorder:   "#3d4e68"

    // Action color groups
    readonly property var success:    ({ text: "#44aa66", bg: "#0f2a1c", bgHov: "#1a3a28", border: "#226644" })
    readonly property var danger:     ({ text: "#cc5555", bg: "#2a0f0f", bgHov: "#3a1515", border: "#882222" })
    readonly property var ctrlStart:  ({ bg: "#1a3a1a", bgHov: "#1a5a1a", text: "#ffffff",  border: "#2a5a2a" })
    readonly property var ctrlStop:   ({ bg: "#4a1a1a", bgHov: "#5a1a1a", text: "#ff6666" })
    readonly property var cancel:     ({ bg: "#1a1a2e", bgHov: "#2a1a2e" })
    readonly property var saveTo:     ({ bg: "#1a1a0f", bgHov: "#2a2a1a", text: "#aaaa44",  border: "#666622" })
    readonly property var primary:    ({ bg: "#6366f1", bgHov: "#7577f3", text: "#ffffff",  border: "#6366f1" })
    readonly property var run:        ({ bg: "#0f2a18", bgHov: "#1a4a2a", text: "#55ee88",  border: "#338855" })
    readonly property var btnAdd:     ({ bg: "#2a2060", bgHov: "#3a30a0", text: "#818cf8",  border: "#4a40a0" })
    readonly property var btnBrowse:  ({ bg: "#181a2e", bgHov: "#253050", text: "#88aaff",  border: "#2a2c4e" })
    readonly property var cancelDlg:  ({ bg: "transparent", bgHov: "#3a3a3a", border: "#666688" })
    readonly property var confirmDlg: ({ bg: "#6366f1",     bgHov: "#7577f3", text: "#ffffff",  border: "#6366f1" })
    readonly property var deleteBtn:  ({ hoverBg: "#3a1010", hoverText: "#cc5555", text: "#776688" })
    readonly property var btnDefault: ({ bg: "#1a2035", text: "#88aaff" })

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
    function healthColor(status) {
        const s = status.toLowerCase()
        if (s === "abnormal") return anomaly
        if (s === "warning")  return warning
        if (s === "normal")   return normal
        if (s === "n/a")      return stopped
        if (s === "start")    return white
        if (s === "stop")     return stopped
        return textMuted
    }
}
