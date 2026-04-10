#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QStandardPaths>

#include "backend/EquipmentManager.h"
#include "backend/DatabaseManager.h"

// Qt 리소스에 embed된 ONNX 모델을 임시 경로로 추출
static QString extractModelToTemp()
{
    const QString src = ":/models/equipment_anomaly_rf.onnx";
    const QString dst = QStandardPaths::writableLocation(
                            QStandardPaths::TempLocation)
                        + "/equipment_anomaly_rf.onnx";
    QFile::remove(dst);
    QFile::copy(src, dst);
    QFile::setPermissions(dst, QFile::ReadOwner | QFile::WriteOwner);
    return dst;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    DatabaseManager::instance().init();

    const QString modelPath = extractModelToTemp();
    EquipmentManager equipmentManager(modelPath);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("equipmentManager", &equipmentManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("QtFacility", "Main");
    return app.exec();
}
