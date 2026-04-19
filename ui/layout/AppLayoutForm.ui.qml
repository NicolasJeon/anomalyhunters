import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"

// App layout
Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing:      0

        HeaderLayout {
            Layout.fillWidth:       true
            Layout.preferredHeight: 56
        }

        SplitView {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            orientation:       Qt.Horizontal

            MasterLayout {
                SplitView.preferredWidth: 260
                SplitView.minimumWidth:   200
                SplitView.maximumWidth:   420
            }

            DetailLayout {
                SplitView.fillWidth:    true
                SplitView.minimumWidth: 560
            }
        }
    }
}
