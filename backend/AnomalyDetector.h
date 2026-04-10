#pragma once

#include <string>

class AnomalyDetector
{
public:
    static constexpr int FEATURE_SIZE = 2;   // [temperature, power]

    // label: 0 = normal, 1 = warning, 2 = abnormal
    struct Result {
        int   label         = -1;
        float prob_normal   = 0.0f;
        float prob_warning  = 0.0f;
        float prob_abnormal = 0.0f;
    };

    explicit AnomalyDetector(const std::string& modelPath);
    ~AnomalyDetector();

    // 단일 (temperature, power) 샘플로 즉시 추론
    Result predict(float temperature, float power);


private:
    // ONNX Runtime objects (heap-allocated to avoid include cascade)
    struct OrtImpl;
    OrtImpl* ort_ = nullptr;
};
