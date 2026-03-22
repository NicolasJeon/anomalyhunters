#pragma once

#include <random>

// 정상 + 이상 패턴을 생성하는 순수 C++ 시뮬레이터.
// 각 장비 인스턴스마다 독립적인 RNG 상태를 가진다.
class DeviceTimeSeriesSimulator
{
public:
    struct Sample { float temperature; float power; };

    explicit DeviceTimeSeriesSimulator();

    Sample next();

    bool inAnomalyWindow() const { return anomalyTicksLeft_ > 0; }

private:
    std::mt19937                          rng_;
    std::normal_distribution<float>       normDist_{0.f, 1.f};
    std::uniform_int_distribution<int>    intDist2_{0, 2};

    float baseTemp_         = 33.f;
    int   normalTickCount_  = 0;
    int   anomalyTicksLeft_ = 0;
    int   anomalyType_      = 0;
    int   anomalyInterval_  = 25;

    static constexpr float TEMP_LOW  = 28.f;
    static constexpr float TEMP_HIGH = 45.f;
    static constexpr float PWR_LOW   = 40.f;
    static constexpr float PWR_HIGH  = 80.f;
};
