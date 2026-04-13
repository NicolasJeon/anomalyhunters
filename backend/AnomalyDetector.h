#pragma once

class AnomalyDetector
{
public:
    // label: 0 = Normal, 1 = Warning, 2 = Abnormal
    struct Result {
        int   label         = -1;
        float abnormal_dist = 0.0f;   // 0.0 (정상 범위) ~ 1.0 (Abnormal 임계값)
    };

    AnomalyDetector() = default;

    // dist = clamp(temp_dist + power_dist * 0.4, 0, 1)
    //   temp_dist  = (temp  - 28) / (60 - 28)
    //   power_dist = (power - 40) / (80 - 40)
    //
    //   dist >= 0.75 → Abnormal
    //   dist >= 0.50 → Warning
    //   dist <  0.50 → Normal
    Result predict(float temperature, float power);
};
