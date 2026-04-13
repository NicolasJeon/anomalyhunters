pragma Singleton
import QtQuick

// 앱 전체 공통 색상 상수 모음
//
// 이 파일 하나만 수정하면 앱 전체 색상 테마를 바꿀 수 있습니다.
//
// 사용 예)
//   color: Constant.normal
//   color: Constant.healthColor(device.healthStatus)
QtObject {

    // ── 배경 ──────────────────────────────────────────────────────────────
    readonly property color bgWindow: "#12141f"   // 앱 전체 배경
    readonly property color bgPanel:  "#0e1020"   // 패널 / 리스트 배경
    readonly property color bgCard:   "#181a2e"   // 카드 / 헤더 배경

    // ── 테두리 ────────────────────────────────────────────────────────────
    readonly property color border: "#2a2c4e"     // 기본 테두리

    // ── 텍스트 ────────────────────────────────────────────────────────────
    readonly property color textPrimary:   "#e0e0f8"  // 주요 텍스트 (이름 등)
    readonly property color textSecondary: "#666688"  // 보조 텍스트 (타입 등)
    readonly property color textLabel:     "#7777aa"  // 레이블 (섹션 제목 등)
    readonly property color textMuted:     "#444466"  // 흐린 텍스트 / 플레이스홀더

    // ── 상태 색상 ─────────────────────────────────────────────────────────
    readonly property color normal:    "#44cc77"   // Normal health
    readonly property color warning:   "#d89050"   // Warning health
    readonly property color anomaly:   "#cc3344"   // Abnormal health
    readonly property color emergency: "#ff4400"   // Emergency stop
    readonly property color waiting:   "#4488cc"   // Inference pending (label -1)
    readonly property color stopped:   "#8899aa"   // Stopped / inactive

    // ── 센서 수치 색상 ────────────────────────────────────────────────────
    readonly property color sensorTemp:  "#66ddaa"   // Temperature value text
    readonly property color sensorPower: "#66aaff"   // Power value text

    // ── 차트 슬롯 배경 ───────────────────────────────────────────────────
    readonly property color chartSlotBg: "#1a1c2e"   // 히스토리 바 빈 슬롯

    // ── 게이지 바 색상 ────────────────────────────────────────────────────
    readonly property color gaugeNormal:   "#1a7a4a"   // Normal probability bar
    readonly property color gaugeAbnormal: "#9b2335"   // Abnormal probability bar
    readonly property color gaugeWarning:  "#c87941"   // Warning bar (chart)
    readonly property color gaugeTemp:     "#1a8899"   // Temperature history bar
    readonly property color gaugePower:    "#2255cc"   // Power history bar
    readonly property color gaugeBg:       "#0e1020"   // Gauge track background

    // ── 선택 / 포커스 ─────────────────────────────────────────────────────
    readonly property color selectionBg:     "#1e2a46"   // Selected list item bg
    readonly property color selectionBorder: "#4466cc"   // Selected list item border
    readonly property color focusAccent:     "#5599ff"   // Focus ring / press highlight

    // ── 로그 행 ───────────────────────────────────────────────────────────
    readonly property color logRowBg:       "#13152a"   // Default log row bg
    readonly property color logRowAbnormal: "#441520"   // Abnormal row tint
    readonly property color logRowWarning:  "#3d2810"   // Warning row tint
    readonly property color logSubText:     "#aabbcc"   // Timestamp / muted log text

    // ── 다이얼로그 배경 ───────────────────────────────────────────────────
    readonly property color bgDialog:  "#0d0f1c"   // Popup / dialog background

    // ── 성공 액션 (저장, 확인) ────────────────────────────────────────────
    readonly property color successText:   "#44aa66"   // Success label text
    readonly property color successBg:     "#0f2a1c"   // Success button bg
    readonly property color successBgHov:  "#1a3a28"   // Success button hover
    readonly property color successBorder: "#226644"   // Success button border

    // ── 위험 액션 (삭제, 클리어) ──────────────────────────────────────────
    readonly property color dangerText:   "#cc5555"   // Danger label text
    readonly property color dangerBg:     "#2a0f0f"   // Danger button bg
    readonly property color dangerBgHov:  "#3a1515"   // Danger button hover
    readonly property color dangerBorder: "#882222"   // Danger button border

    // ── 제어 버튼 (Start / Stop / Delete) ────────────────────────────────
    readonly property color ctrlStartBg:     "#1a3a1a"
    readonly property color ctrlStartBgHov:  "#1a5a1a"
    readonly property color ctrlStartText:   "#ffffff"
    readonly property color ctrlStartBorder: "#2a5a2a"

    readonly property color ctrlStopBg:      "#4a1a1a"
    readonly property color ctrlStopBgHov:   "#5a1a1a"
    readonly property color ctrlStopText:    "#ff6666"

    readonly property color ctrlDeleteBg:     "#1e1e2e"
    readonly property color ctrlDeleteBgHov:  "#3a1a1a"
    readonly property color ctrlDeleteText:   "#aa4444"
    readonly property color ctrlDeleteBorder: "#2a2a3e"

    // ── 테스트 모드 ───────────────────────────────────────────────────────
    readonly property color testModeBg:     "#2a1040"   // Test mode badge bg
    readonly property color testModeBorder: "#aa44ff"   // Test mode badge border
    readonly property color testModeText:   "#cc88ff"   // Test mode badge text

    // ── 센서 포맷 함수 ────────────────────────────────────────────────────
    function formatTemp(value)  { return value.toFixed(1) + " °C" }
    function formatPower(value) { return value.toFixed(1) + " W"  }

    // ── 상태 → 색상 변환 함수 ─────────────────────────────────────────────
    // HealthStatus:  "N/A" | "Normal" | "Warning" | "Abnormal"
    // EventType:     "start" | "stop"  (ctrl event color alias)
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
