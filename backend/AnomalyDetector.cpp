#include "AnomalyDetector.h"
#include <algorithm>

AnomalyDetector::Result AnomalyDetector::predict(int temperature, int power)
{
    Result res;

    // temp: <40 Normal, 40-50 Warning, >=50 Abnormal
    if      (temperature >= 50) res.tempState  = State::Abnormal;
    else if (temperature >= 40) res.tempState  = State::Warning;
    else                        res.tempState  = State::Normal;

    // power: <60 Normal, 60-90 Warning, >=90 Abnormal
    if      (power >= 90) res.powerState = State::Abnormal;
    else if (power >= 60) res.powerState = State::Warning;
    else                  res.powerState = State::Normal;

    res.finalState = std::max(res.tempState, res.powerState);

    return res;
}
