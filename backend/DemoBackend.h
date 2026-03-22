#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <random>

#include "AnomalyDetector.h"

// QObject 기반 백엔드. QML에 데이터를 노출하고 시뮬레이션을 구동한다.
class DemoBackend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(float   temperature  READ temperature  NOTIFY dataChanged)
    Q_PROPERTY(float   power        READ power        NOTIFY dataChanged)
    Q_PROPERTY(int     label        READ label        NOTIFY dataChanged)
    Q_PROPERTY(float   probNormal   READ probNormal   NOTIFY dataChanged)
    Q_PROPERTY(float   probAbnormal READ probAbnormal NOTIFY dataChanged)
    Q_PROPERTY(QString statusText   READ statusText   NOTIFY dataChanged)
    Q_PROPERTY(QVariantList historyModel READ historyModel NOTIFY dataChanged)

public:
    explicit DemoBackend(const QString& modelPath, QObject* parent = nullptr);

    float        temperature()  const { return temperature_; }
    float        power()        const { return power_; }
    int          label()        const { return label_; }
    float        probNormal()   const { return probNormal_; }
    float        probAbnormal() const { return probAbnormal_; }
    QString      statusText()   const;
    QVariantList historyModel() const { return history_; }

signals:
    void dataChanged();

private slots:
    void tick();

private:
    void generateSample(float& outTemp, float& outPower);

    AnomalyDetector detector_;
    QTimer          timer_;

    std::mt19937                          rng_{42};
    std::normal_distribution<float>       normDist_{0.0f, 1.0f};
    std::uniform_real_distribution<float> uniformDist_{0.0f, 1.0f};

    // 현재 값
    float   temperature_  = 33.0f;
    float   power_        = 0.0f;
    int     label_        = -1;
    float   probNormal_   = 0.0f;
    float   probAbnormal_ = 0.0f;

    // 이상 주입 제어
    int normalTickCount_  = 0;   // 연속 정상 tick 수
    int anomalyTicksLeft_ = 0;   // 남은 이상 tick 수
    int anomalyType_      = 0;   // 0=고온 1=전력급증 2=관계붕괴

    // 히스토리 (최근 HISTORY_SIZE 개)
    QVariantList history_;
    static constexpr int HISTORY_SIZE = 20;
    static constexpr int ANOMALY_INTERVAL = 25; // N tick마다 이상 주입
    static constexpr int ANOMALY_DURATION =  8; // 이상 지속 tick 수
};
