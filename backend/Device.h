#pragma once

#include <QVariantMap>
#include <QString>

// ── TimeSeriesSample ─────────────────────────────────────────────────────────
struct TimeSeriesSample {
    qint64 timestampMs  = 0;
    float  temperature  = 0.f;
    float  power        = 0.f;
    // 추론 결과도 함께 저장해 히스토리 바 색상에 사용
    int    label        = -1;
    float  probAbnormal = 0.f;

    QVariantMap toVariantMap() const {
        return {
            { "timestampMs",   timestampMs  },
            { "temperature",   temperature  },
            { "power",         power        },
            { "label",         label        },
            { "probAbnormal",  probAbnormal }
        };
    }
};

// ── InferenceState ───────────────────────────────────────────────────────────
struct InferenceState {
    int     label        = -1;
    float   probNormal   = 0.f;
    float   probWarning  = 0.f;
    float   probAbnormal = 0.f;

    QString statusText() const {
        if (label == -1) return QStringLiteral("Buffering...");
        if (label ==  0) return QStringLiteral("Normal");
        if (label ==  1) return QStringLiteral("Warning");
        return QStringLiteral("ABNORMAL");
    }

    QVariantMap toVariantMap() const {
        return {
            { "label",        label        },
            { "probNormal",   probNormal   },
            { "probWarning",  probWarning  },
            { "probAbnormal", probAbnormal },
            { "statusText",   statusText() }
        };
    }
};

// ── Device ───────────────────────────────────────────────────────────────────
struct Device {
    QString id;
    QString name;
    QString type;
    QString healthStatus;    // normal | warning | anomaly
    QString controlStatus;   // stopped | running
    QString imageSource;

    QVariantMap toVariantMap() const {
        return {
            { "id",            id            },
            { "name",          name          },
            { "type",          type          },
            { "healthStatus",  healthStatus  },
            { "controlStatus", controlStatus },
            { "imageSource",   imageSource   }
        };
    }
};
