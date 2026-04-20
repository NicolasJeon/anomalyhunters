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

    void reset() { seqIdx_ = 0; tickCount_ = 0; }

private:
    struct StateSpec { int tempState; int powerState; };

    static constexpr std::array<StateSpec, 8> SEQ = {{
        {0, 0},
        {1, 0},
        {2, 1},
        {0, 1},
        {0, 0},
        {1, 2},
        {1, 1},
        {0, 0},
    }};
    static constexpr int TICKS_PER_STATE = 5;

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
