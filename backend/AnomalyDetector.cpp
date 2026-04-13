#include "AnomalyDetector.h"

AnomalyDetector::Result AnomalyDetector::predict(float temperature, float power)
{
    Result res;

    if (temperature >= 60.0f) {
        res.label         = 2;
        res.prob_abnormal = 1.0f;
    } else if (temperature >= 50.0f || power >= 80.0f) {
        res.label        = 1;
        res.prob_warning = 1.0f;
    } else {
        res.label       = 0;
        res.prob_normal = 1.0f;
    }

    return res;
}
