#pragma once

#include <QVariantMap>
#include <QString>
#include <QDateTime>

// ── TimeSeriesSample ─────────────────────────────────────────────────────────
struct TimeSeriesSample {
    qint64 timestampMs  = 0;
    int    temperature  = 0;
    int    power        = 0;
    int    label        = -1;

    QVariantMap toVariantMap() const {
        return {
            { "timestampMs",  timestampMs  },
            { "temperature",  temperature  },
            { "power",        power        },
            { "label",        label        }
        };
    }
};

// ── InferenceState ───────────────────────────────────────────────────────────
struct InferenceState {
    int     label = -1;

    QString statusText() const {
        if (label == -1) return QStringLiteral("N/A");
        if (label ==  0) return QStringLiteral("Normal");
        if (label ==  1) return QStringLiteral("Warning");
        return QStringLiteral("Abnormal");
    }

    QVariantMap toVariantMap() const {
        return {
            { "label",      label        },
            { "statusText", statusText() }
        };
    }
};

// ── StateLogEntry ─────────────────────────────────────────────────────────────
struct StateLogEntry {
    quint64 logId         = 0;
    qint64  timestampMs   = 0;
    QString event;
    QString healthStatus;
    QString controlStatus;
    int     temperature   = 0;
    int     power         = 0;
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
    QString healthStatus;
    QString controlStatus;
    QString imageSource;
    QString ip;

    QVariantMap toVariantMap() const {
        return {
            { "id",            id            },
            { "name",          name          },
            { "healthStatus",  healthStatus  },
            { "controlStatus", controlStatus },
            { "imageSource",   imageSource   },
            { "ip",            ip            }
        };
    }
};
