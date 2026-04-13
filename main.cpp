#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "backend/EquipmentManager.h"
#include "backend/DatabaseManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    DatabaseManager::instance().init();

    EquipmentManager equipmentManager;

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
