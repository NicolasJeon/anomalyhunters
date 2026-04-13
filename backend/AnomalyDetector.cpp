#include "AnomalyDetector.h"

#include <algorithm>

AnomalyDetector::Result AnomalyDetector::predict(float temperature, float power)
{
    // ── 정규화 ────────────────────────────────────────────────────────────
    // temp:  28°C → 0.0 / 60°C → 1.0
    // power: 40W  → 0.0 / 80W  → 1.0
    constexpr float TEMP_MIN  = 28.0f;  constexpr float TEMP_MAX  = 60.0f;
    constexpr float POWER_MIN = 40.0f;  constexpr float POWER_MAX = 80.0f;
    constexpr float W         = 0.4f;   // power 단독 최대 0.4 → Abnormal 불가

    const float temp_dist  = std::clamp((temperature - TEMP_MIN) / (TEMP_MAX  - TEMP_MIN),  0.0f, 1.0f);
    const float power_dist = std::clamp((power       - POWER_MIN) / (POWER_MAX - POWER_MIN), 0.0f, 1.0f);

    Result res;
    res.abnormal_dist = std::clamp(temp_dist + power_dist * W, 0.0f, 1.0f);

    // ── label (dist 기반) ─────────────────────────────────────────────────
    // temp=50, power=40  → dist ≈ 0.69          → Warning
    // temp=50, power=80  → dist ≈ 0.69+0.4=1.09 → Abnormal
    // temp=60, power=40  → dist = 1.0            → Abnormal
    // power=80 단독      → dist = 0.4            → Normal~Warning 경계
    if      (res.abnormal_dist >= 0.75f) res.label = 2;  // Abnormal
    else if (res.abnormal_dist >= 0.50f) res.label = 1;  // Warning
    else                                 res.label = 0;  // Normal

    return res;
}
