#include "DeviceTimeSeriesSimulator.h"

#include <algorithm>

DeviceTimeSeriesSimulator::DeviceTimeSeriesSimulator(int seqOffset)
    : rng_(std::random_device{}())
    , seqIdx_(seqOffset % static_cast<int>(SEQ.size()))
{
}

DeviceTimeSeriesSimulator::Sample DeviceTimeSeriesSimulator::next()
{
    const int state = SEQ[seqIdx_];

    float baseTemp = (state == 2) ? TEMP_ABNORMAL
                   : (state == 1) ? TEMP_WARNING
                   :                TEMP_NORMAL;
    float basePwr  = (state == 2) ? PWR_ABNORMAL
                   : (state == 1) ? PWR_WARNING
                   :                PWR_NORMAL;

    const float t = std::clamp(baseTemp + noise_(rng_), 28.0f, 65.0f);
    const float p = std::clamp(basePwr  + noise_(rng_), 40.0f, 80.0f);

    // 다음 틱으로 이동
    if (++tickCount_ >= TICKS_PER_STATE) {
        tickCount_ = 0;
        seqIdx_ = (seqIdx_ + 1) % static_cast<int>(SEQ.size());
    }

    return {t, p};
}
