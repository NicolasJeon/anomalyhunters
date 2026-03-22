#include "DemoBackend.h"

#include <QVariantMap>
#include <algorithm>
#include <cmath>

DemoBackend::DemoBackend(const QString& modelPath, QObject* parent)
    : QObject(parent)
    , detector_(modelPath.toStdString())
{
    connect(&timer_, &QTimer::timeout, this, &DemoBackend::tick);
    timer_.start(500);
}

// ── statusText ────────────────────────────────────────────────────────────
QString DemoBackend::statusText() const
{
    if (label_ == -1) return QStringLiteral("Buffering...");
    if (label_ ==  0) return QStringLiteral("Normal");
    return QStringLiteral("ABNORMAL");
}

// ── tick ──────────────────────────────────────────────────────────────────
void DemoBackend::tick()
{
    // ── 샘플 생성 ─────────────────────────────────────────────────────────
    float t, p;
    generateSample(t, p);
    temperature_ = t;
    power_       = p;

    // ── 추론 ─────────────────────────────────────────────────────────────
    auto res  = detector_.push(t, p);
    label_        = res.label;
    probNormal_   = res.prob_normal;
    probAbnormal_ = res.prob_abnormal;

    // ── 히스토리 업데이트 ────────────────────────────────────────────────
    QVariantMap entry;
    entry["temperature"] = t;
    entry["power"]       = p;
    entry["label"]       = res.label;
    entry["probAbnormal"] = res.prob_abnormal;

    history_.append(entry);
    if (history_.size() > HISTORY_SIZE)
        history_.removeFirst();

    emit dataChanged();
}

// ── generateSample ────────────────────────────────────────────────────────
// 정상: 온도 랜덤워크, power = temp*1.5 + noise
// 이상: anomalyType에 따라 값 변조
void DemoBackend::generateSample(float& outTemp, float& outPower)
{
    // ── 이상 주입 스케줄 결정 ─────────────────────────────────────────────
    if (anomalyTicksLeft_ > 0) {
        --anomalyTicksLeft_;
    } else {
        ++normalTickCount_;
        if (normalTickCount_ >= ANOMALY_INTERVAL) {
            normalTickCount_ = 0;
            anomalyTicksLeft_ = ANOMALY_DURATION;
            // 0~2 중 랜덤 선택
            anomalyType_ = static_cast<int>(
                std::uniform_int_distribution<int>(0, 2)(rng_));
        }
    }

    // ── 정상 기저 값 생성 ─────────────────────────────────────────────────
    float nextTemp = temperature_ + normDist_(rng_) * 0.8f;
    nextTemp = std::clamp(nextTemp, 28.0f, 45.0f);

    float nextPower = nextTemp * 1.5f + normDist_(rng_) * 2.0f;
    nextPower = std::clamp(nextPower, 40.0f, 80.0f);

    // ── 이상 주입 ─────────────────────────────────────────────────────────
    if (anomalyTicksLeft_ > 0) {
        switch (anomalyType_) {
        case 0:  // A. 고온 이상
            nextTemp  = std::clamp(nextTemp  + 20.0f, 0.0f, 100.0f);
            break;
        case 1:  // B. 전력 급증
            nextPower = std::clamp(nextPower + 35.0f, 0.0f, 200.0f);
            break;
        case 2:  // C. 관계 붕괴 (온도 보통, 전력 과도)
            nextPower = std::clamp(nextPower + 38.0f, 0.0f, 200.0f);
            break;
        }
    }

    // 정상 경우에만 온도 상태 갱신 (이상 중에는 기저 온도 유지)
    if (anomalyTicksLeft_ == 0)
        temperature_ = nextTemp;

    outTemp  = nextTemp;
    outPower = nextPower;
}
