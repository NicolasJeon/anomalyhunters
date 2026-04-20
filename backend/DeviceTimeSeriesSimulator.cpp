#include "DeviceTimeSeriesSimulator.h"

#include <algorithm>

DeviceTimeSeriesSimulator::DeviceTimeSeriesSimulator(int seqOffset)
    : rng_(std::random_device{}())
    , seqIdx_(seqOffset % static_cast<int>(SEQ.size()))
{
}

DeviceTimeSeriesSimulator::Sample DeviceTimeSeriesSimulator::next()
{
    const StateSpec& spec = SEQ[seqIdx_];

    float baseTemp = (spec.tempState == 2) ? TEMP_ABNORMAL
                   : (spec.tempState == 1) ? TEMP_WARNING
                   :                         TEMP_NORMAL;
    float basePwr  = (spec.powerState == 2) ? PWR_ABNORMAL
                   : (spec.powerState == 1) ? PWR_WARNING
                   :                          PWR_NORMAL;

    const int t = std::clamp(static_cast<int>(std::round(baseTemp + noise_(rng_))), 10, 70);
    const int p = std::clamp(static_cast<int>(std::round(basePwr  + noise_(rng_))), 10, 100);

    if (++tickCount_ >= TICKS_PER_STATE) {
        tickCount_ = 0;
        seqIdx_ = (seqIdx_ + 1) % static_cast<int>(SEQ.size());
    }

    return {t, p};
}
