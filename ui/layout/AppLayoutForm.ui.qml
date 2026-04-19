import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"

// App layout — structure only
Item {
    id: root

    // ── Practice #1: Master-Detail UI layout ──────────────────────────────────
    // Mission: ColumnLayout + SplitView로 Header / Master / Detail 영역 구성
    // Hints:   ColumnLayout (QtQuick.Layouts)
    //          SplitView    (QtQuick.Controls)
    //
    // ── Practice #2: Responsive layout ───────────────────────────────────────
    // Mission: 창 크기에 따라 레이아웃이 반응하도록 설정
    // Hints:   Layout.fillWidth / Layout.fillHeight
    //
    // ── Answer (먼저 직접 해보세요!) ──────────────────────────────────────────
    // // ColumnLayout {
    // //     anchors.fill: parent
    // //     spacing:      0
    // //
    // //     HeaderLayout {               // Practice #1
    // //         Layout.fillWidth: true   // Practice #2
    // //     }
    // //
    // //     SplitView {                       // Practice #1
    // //         Layout.fillWidth:  true       // Practice #2
    // //         Layout.fillHeight: true       // Practice #2
    // //         orientation:       Qt.Horizontal
    // //
    // //         MasterLayout {
    // //             SplitView.preferredWidth: 260
    // //             SplitView.minimumWidth:   200
    // //             SplitView.maximumWidth:   420
    // //         }
    // //
    // //         DetailLayout {
    // //             SplitView.fillWidth:    true
    // //             SplitView.minimumWidth: 560
    // //         }
    // //     }
    // // }

    HeaderLayout  { id: appHeader    }
    MasterLayout  { id: masterLayout }
    DetailLayout  { id: detailLayout }
}
