#pragma once
#include <QString>
#include <QVariantMap>

struct Equipment {
    QString id;
    QString name;
    QString ip;
    QString imageSource;
    bool    running = false;

    QVariantMap toVariantMap() const {
        return {
            { "id",          id          },
            { "name",        name        },
            { "ip",          ip          },
            { "imageSource", imageSource },
            { "running",     running     },
        };
    }
};
