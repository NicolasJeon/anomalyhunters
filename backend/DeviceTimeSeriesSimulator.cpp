#include "DeviceTimeSeriesSimulator.h"

#include <algorithm>

DeviceTimeSeriesSimulator::DeviceTimeSeriesSimulator()
    : rng_(std::random_device{}())
{
    // 장비마다 다른 주기 시작점
    anomalyInterval_ = std::uniform_int_distribution<int>(20, 30)(rng_);
    baseTemp_ = std::uniform_real_distribution<float>(30.f, 36.f)(rng_);
}

DeviceTimeSeriesSimulator::Sample DeviceTimeSeriesSimulator::next()
{
    // ── 이상 주입 스케줄 ─────────────────────────────────────────────────────
    if (anomalyTicksLeft_ > 0) {
        --anomalyTicksLeft_;
    } else {
        ++normalTickCount_;
        if (normalTickCount_ >= anomalyInterval_) {
            normalTickCount_  = 0;
            anomalyTicksLeft_ = std::uniform_int_distribution<int>(5, 10)(rng_);
            anomalyInterval_  = std::uniform_int_distribution<int>(20, 30)(rng_);
            anomalyType_      = intDist2_(rng_);
        }
    }

    // ── 정상 기저 값 ──────────────────────────────────────────────────────────
    float t = std::clamp(baseTemp_ + normDist_(rng_) * 0.8f, TEMP_LOW, TEMP_HIGH);
    float p = std::clamp(t * 1.5f  + normDist_(rng_) * 2.0f, PWR_LOW,  PWR_HIGH);

    // ── 이상 변조 ─────────────────────────────────────────────────────────────
    if (anomalyTicksLeft_ > 0) {
        switch (anomalyType_) {
        case 0: t = std::clamp(t + 20.f, 0.f, 100.f); break;   // A. 고온
        case 1: p = std::clamp(p + 35.f, 0.f, 200.f); break;   // B. 전력 급증
        case 2: p = std::clamp(p + 38.f, 0.f, 200.f); break;   // C. 관계 붕괴
        }
    }

    // 정상 구간에서만 기저 온도 갱신
    if (anomalyTicksLeft_ == 0)
        baseTemp_ = t;

    return {t, p};
}
