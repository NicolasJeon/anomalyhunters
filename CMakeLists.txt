cmake_minimum_required(VERSION 3.16)

project(QtFacility VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appAnomalyHunters
    main.cpp
)

# ── Constant.qml 싱글톤 선언 ─────────────────────────────────────────────
set_source_files_properties(ui/components/Constant.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# ── QML 모듈 ──────────────────────────────────────────────────────────────
qt_add_qml_module(appAnomalyHunters
    URI QtFacility
    VERSION 1.0
    SOURCES
        backend/Equipment.h
        backend/EquipmentListModel.h
        backend/EquipmentListModel.cpp
        backend/EquipmentManager.h
        backend/EquipmentManager.cpp
    QML_FILES
        ui/Main.qml
        # layout
        ui/layout/AppLayout.qml
        ui/layout/AppLayoutForm.ui.qml
        ui/layout/HeaderLayout.qml
        ui/layout/MasterLayout.qml
        ui/layout/MasterLayoutForm.ui.qml
        ui/layout/DetailLayout.qml
        ui/layout/DetailLayoutForm.ui.qml
        # components
        ui/components/Constant.qml
        ui/components/AppButton.qml
        ui/components/ControlSwitch.qml
        ui/components/EquipmentList.qml
        ui/components/EquipmentDelegate.qml
        ui/components/StatusCard.qml
        ui/components/ImageCard.qml
        ui/components/SensorRow.qml
)

qt_add_resources(appAnomalyHunters "app_images"
    PREFIX "/images"
    BASE   "images"
    FILES
        images/air_circulator.png
        images/temp_controller.png
        images/pump.png
        images/generator.png
        images/default.png
        images/temperature_icon.svg
        images/power_icon.svg
)

set_target_properties(appAnomalyHunters PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appAnomalyHunters PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/backend
)

target_link_libraries(appAnomalyHunters
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appAnomalyHunters
    BUNDLE  DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
