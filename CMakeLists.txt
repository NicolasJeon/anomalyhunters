cmake_minimum_required(VERSION 3.16)

project(QtFacility VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickDialogs2 Sql Graphs Svg)

qt_standard_project_setup(REQUIRES 6.8)

# ── 실행 파일 ──────────────────────────────────────────────────────────────
qt_add_executable(appAnomalyHunters
    main.cpp
    # backend
    backend/Equipment.h
    backend/AnomalyDetector.h
    backend/AnomalyDetector.cpp
    backend/DeviceTimeSeriesSimulator.h
    backend/DeviceTimeSeriesSimulator.cpp
    backend/EquipmentManager.h
    backend/EquipmentManager.cpp
    backend/EquipmentMonitor.h
    backend/EquipmentMonitor.cpp
    backend/DatabaseManager.h
    backend/DatabaseManager.cpp
)

# ── Constant.qml 싱글톤 선언 ─────────────────────────────────────────────
set_source_files_properties(ui/components/Constant.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# ── QML 모듈 ──────────────────────────────────────────────────────────────
qt_add_qml_module(appAnomalyHunters
    URI QtFacility
    VERSION 1.0
    QML_FILES
        ui/Main.qml
        # layout — 화면 전체 구성
        ui/layout/AppLayout.qml
        ui/layout/AppLayoutForm.ui.qml
        ui/layout/HeaderLayout.qml
        ui/layout/MasterLayout.qml
        ui/layout/MasterLayoutForm.ui.qml
        ui/layout/DetailLayout.qml
        ui/layout/DetailLayoutForm.ui.qml
        # components — 재사용 UI 요소
        ui/components/AppButton.qml
        ui/components/Constant.qml
        ui/components/LabeledInput.qml
        ui/components/SensorRow.qml
        ui/components/ControlSwitch.qml
        ui/components/EquipmentHeader.qml
        ui/components/EquipmentListItem.qml
        ui/components/HistoryChart.qml
        ui/components/ImageCard.qml
        ui/components/StateLogList.qml
        ui/components/StateLogPanel.qml
        ui/components/StatusCard.qml
        # dialogs — 모달 오버레이
        ui/dialogs/EquipmentDialog.qml
        ui/dialogs/ManualSaveDialog.qml
        ui/dialogs/StateLogDialog.qml
        ui/dialogs/TestDataDialog.qml
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
        images/logo.svg
        images/temperature_icon.svg
        images/power_icon.svg
)

set_target_properties(appAnomalyHunters PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appAnomalyHunters PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}   # main.cpp에서 "backend/..." include 가능
)

target_link_libraries(appAnomalyHunters
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::QuickDialogs2
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Graphs
    PRIVATE Qt6::Svg
)

include(GNUInstallDirs)
install(TARGETS appAnomalyHunters
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
