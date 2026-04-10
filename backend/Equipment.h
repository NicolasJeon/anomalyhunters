#pragma once

#include <QVariantMap>
#include <QString>
#include <QDateTime>

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
        if (label == -1) return QStringLiteral("N/A");
        if (label ==  0) return QStringLiteral("Normal");
        if (label ==  1) return QStringLiteral("Warning");
        return QStringLiteral("Abnormal");
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

// ── StateLogEntry ─────────────────────────────────────────────────────────────
struct StateLogEntry {
    quint64 logId         = 0;   // session-scoped unique ID (not persisted to DB)
    qint64  timestampMs   = 0;
    QString event;        // "start" | "stop" | "health_change"
    QString healthStatus;
    QString controlStatus;
    float   temperature   = 0.f;
    float   power         = 0.f;
    bool    savedToDB     = false;

    QVariantMap toVariantMap() const {
        return {
            { "logId",         static_cast<qulonglong>(logId) },
            { "timestampMs",   timestampMs   },
            { "event",         event         },
            { "healthStatus",  healthStatus  },
            { "controlStatus", controlStatus },
            { "temperature",   temperature   },
            { "power",         power         },
            { "savedToDB",     savedToDB     }
        };
    }
};

// ── Equipment ────────────────────────────────────────────────────────────────
struct Equipment {
    QString id;
    QString name;
    QString healthStatus;    // N/A | Normal | Warning | Abnormal
    QString controlStatus;   // Stopped | Running
    QString imageSource;

    QVariantMap toVariantMap() const {
        return {
            { "id",            id            },
            { "name",          name          },
            { "healthStatus",  healthStatus  },
            { "controlStatus", controlStatus },
            { "imageSource",   imageSource   }
        };
    }
};
