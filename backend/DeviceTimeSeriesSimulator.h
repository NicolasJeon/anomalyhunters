#pragma once

#include <random>
#include <array>

// Fixed-sequence simulator: 0=Normal 1=Warning 2=Abnormal
class DeviceTimeSeriesSimulator
{
public:
    struct Sample { int temperature; int power; };

    explicit DeviceTimeSeriesSimulator(int seqOffset = 0);

    Sample next();

    bool inAnomalyWindow() const {
        return SEQ[seqIdx_].tempState == 2 || SEQ[seqIdx_].powerState == 2;
    }

private:
    struct StateSpec { int tempState; int powerState; };

    // Sequence N→W→A→W→N→A→W→N with varied temp/power combinations
    static constexpr std::array<StateSpec, 8> SEQ = {{
        {0, 0},  // N: temp Normal,    power Normal
        {1, 0},  // W: temp Warning,   power Normal
        {2, 1},  // A: temp Abnormal,  power Warning
        {0, 1},  // W: temp Normal,    power Warning
        {0, 0},  // N: temp Normal,    power Normal
        {1, 2},  // A: temp Warning,   power Abnormal
        {1, 1},  // W: temp Warning,   power Warning
        {0, 0},  // N: temp Normal,    power Normal
    }};
    static constexpr int TICKS_PER_STATE = 5;

    // Base values (AnomalyDetector thresholds: temp 40/50, power 60/90)
    static constexpr int TEMP_NORMAL   = 28;
    static constexpr int TEMP_WARNING  = 44;
    static constexpr int TEMP_ABNORMAL = 54;
    static constexpr int PWR_NORMAL    = 40;
    static constexpr int PWR_WARNING   = 72;
    static constexpr int PWR_ABNORMAL  = 94;

    std::mt19937                    rng_;
    std::normal_distribution<float> noise_{0.f, 0.6f};

    int seqIdx_    = 0;
    int tickCount_ = 0;
};
