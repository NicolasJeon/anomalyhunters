import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"

// App layout — structure only
Item {
    id: root

    // ── Practice #1: Master-Detail UI layout ──────────────────────────────────
    // Mission: Header / Master / Detail 영역 구성
    // Hints:   1) ColumnLayout (anchors.fill: parent / spacing: 0) 으로 전체를 세로로 나눈다
    //             └─ 위: HeaderLayout (width: parent.width / height: 56)
    //             └─ 아래: SplitView (width: parent.width / height: parent.height - 56)
    //          2) SplitView로 아래 영역을 가로로 나눈다
    //             └─ 왼쪽: MasterLayout (width: 260)  /  오른쪽: DetailLayout (width: 760)

    HeaderLayout  { id: appHeader    }
    MasterLayout  { id: masterLayout }
    DetailLayout  { id: detailLayout }

    // ─────────────────────────────────────────────────────────────────────────
    // ── Practice #1 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    // // ColumnLayout {
    // //     anchors.fill:parent
    // //     spacing: 0
    // //
    // //     HeaderLayout {
    // //         id: appHeader
    // //         width:  parent.width
    // //         height: 56
    // //     }
    // //
    // //     SplitView {
    // //         width:       parent.width
    // //         height:      parent.height - appHeader.height
    // //         orientation: Qt.Horizontal
    // //
    // //         MasterLayout {
    // //             id: masterLayout
    // //             width: 260
    // //         }
    // //
    // //         DetailLayout {
    // //             id: detailLayout
    // //             width: 760
    // //         }
    // //     }
    // // }

    // ── Practice #2: Responsive layout ───────────────────────────────────────
    // Mission: Layout / SplitView 전용 속성으로 반응형 레이아웃 완성
    // Hints:   HeaderLayout  → Layout.fillWidth: true / Layout.preferredHeight: 56
    //          MasterLayout  → SplitView.preferredWidth: 260 / minimumWidth: 200 / maximumWidth: 420
    //          DetailLayout  → SplitView.fillWidth: true / minimumWidth: 560

    // ─────────────────────────────────────────────────────────────────────────
    // ── Practice #2 Answer (먼저 직접 해보세요!) ──────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    // // ColumnLayout {
    // //     anchors.fill: parent
    // //     spacing:      0
    // //
    // //     HeaderLayout {
    // //         Layout.fillWidth:       true
    // //         Layout.preferredHeight: 56
    // //     }
    // //
    // //     SplitView {
    // //         Layout.fillWidth:  true
    // //         Layout.fillHeight: true
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
}
