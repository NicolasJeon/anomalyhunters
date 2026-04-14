#pragma once

class AnomalyDetector
{
public:
    enum class State { Normal, Warning, Abnormal };

    struct Result {
        State tempState  = State::Normal;
        State powerState = State::Normal;
        State finalState = State::Normal;
    };

    AnomalyDetector() = default;

    Result predict(int temperature, int power);
};
