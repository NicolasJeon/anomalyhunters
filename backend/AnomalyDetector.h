#pragma once

class AnomalyDetector
{
public:
    // label: 0 = Normal, 1 = Warning, 2 = Abnormal
    struct Result {
        int   label         = -1;
        float prob_normal   = 0.0f;
        float prob_warning  = 0.0f;
        float prob_abnormal = 0.0f;
    };

    AnomalyDetector() = default;

    // 결정론적 규칙 기반 추론
    //   Abnormal : temperature >= 60
    //   Warning  : (temperature >= 50 && power >= 50) || power >= 60
    //   Normal   : 나머지
    Result predict(float temperature, float power);
};
