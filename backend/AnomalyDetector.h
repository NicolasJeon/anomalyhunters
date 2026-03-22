#pragma once

#include <array>
#include <deque>
#include <string>

class AnomalyDetector
{
public:
    static constexpr int SEQ_LEN      = 10;
    static constexpr int FEATURE_SIZE = 11;

    // label: 0 = normal, 1 = abnormal, -1 = buffer not full yet
    struct Result {
        int   label       = -1;
        float prob_normal = 0.0f;
        float prob_abnormal = 0.0f;
    };

    explicit AnomalyDetector(const std::string& modelPath);
    ~AnomalyDetector();

    // Push one (temperature, power) sample.
    // Returns Result with label == -1 until SEQ_LEN samples are collected.
    Result push(float temperature, float power);

private:
    std::array<float, FEATURE_SIZE> extractFeatures() const;

    std::deque<std::array<float, 2>> buffer_;   // [0]=temp, [1]=power

    // ONNX Runtime objects (heap-allocated to avoid include cascade)
    struct OrtImpl;
    OrtImpl* ort_ = nullptr;
};
