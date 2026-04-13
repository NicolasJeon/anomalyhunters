#pragma once

#include <random>
#include <array>

// 고정 시퀀스 시뮬레이터
// 0=Normal, 1=Warning, 2=Abnormal
class DeviceTimeSeriesSimulator
{
public:
    struct Sample { float temperature; float power; };

    explicit DeviceTimeSeriesSimulator(int seqOffset = 0);

    Sample next();

    bool inAnomalyWindow() const { return SEQ[seqIdx_] == 2; }

private:
    // 시퀀스: 정상→경고→이상→경고→정상→이상→경고→정상
    static constexpr std::array<int, 8> SEQ = { 0, 1, 2, 1, 0, 2, 1, 0 };
    static constexpr int TICKS_PER_STATE = 5;  // 상태당 틱 수

    // 상태별 기준값
    static constexpr float TEMP_NORMAL   = 34.0f;
    static constexpr float TEMP_WARNING  = 44.0f;
    static constexpr float TEMP_ABNORMAL = 52.0f;
    static constexpr float PWR_NORMAL    = 50.0f;
    static constexpr float PWR_WARNING   = 62.0f;
    static constexpr float PWR_ABNORMAL  = 72.0f;

    std::mt19937                    rng_;
    std::normal_distribution<float> noise_{0.f, 0.6f};

    int seqIdx_   = 0;
    int tickCount_ = 0;
};
