cmake_minimum_required(VERSION 3.16)

project(QtFacility VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickDialogs2 Sql Graphs)

qt_standard_project_setup(REQUIRES 6.8)

# ── 실행 파일 ──────────────────────────────────────────────────────────────
qt_add_executable(appQtFacility
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
qt_add_qml_module(appQtFacility
    URI QtFacility
    VERSION 1.0
    QML_FILES
        ui/Main.qml
        # layout — 화면 전체 구성
        ui/layout/MasterDetailLayout.qml
        ui/layout/MasterDetailLayoutForm.ui.qml
        ui/layout/MasterLayout.qml
        ui/layout/MasterLayoutForm.ui.qml
        ui/layout/DetailLayout.qml
        ui/layout/DetailLayoutForm.ui.qml
        # components — 재사용 UI 요소
        ui/components/AppButton.qml
        ui/components/Constant.qml
        ui/components/EquipmentDialog.qml
        ui/components/EquipmentHeader.qml
        ui/components/EquipmentListItem.qml
        ui/components/HistoryChart.qml
        ui/components/ImageCard.qml
        ui/components/ManualSaveDialog.qml
        ui/components/StateLogDialog.qml
        ui/components/StateLogList.qml
        ui/components/StateLogPanel.qml
        ui/components/StatusCard.qml
    RESOURCES
        images/air_circulator.png
        images/temp_controller.png
        images/pump.png
        images/generator.png
        images/default.png
)

set_target_properties(appQtFacility PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appQtFacility PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}   # main.cpp에서 "backend/..." include 가능
)

target_link_libraries(appQtFacility
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::QuickDialogs2
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Graphs
)

include(GNUInstallDirs)
install(TARGETS appQtFacility
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
