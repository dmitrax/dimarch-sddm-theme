// =========================================================
// DimArch — Power Panel
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: powerRoot

    width: 236
    height: 56

    Rectangle {
        id: panelShadowSource
        anchors.fill: panel
        radius: panel.radius
        visible: false
    }

    DropShadow {
        anchors.fill: panelShadowSource
        source: panelShadowSource
        horizontalOffset: 0
        verticalOffset: 8
        radius: 26
        samples: 36
        color: "#20000000"
        cached: true
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 19
        color: "#A8FFFFFF"
        border.color: "#99FFFFFF"
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 36

            PanelIcon {
                symbol: "⏻"
                hoverColor: config.DangerRed
                onClicked: sddm.powerOff()
            }

            PanelIcon {
                symbol: "↻"
                hoverColor: config.TextPrimary
                onClicked: sddm.reboot()
            }

            PanelIcon {
                symbol: "▦"
                hoverColor: config.TextPrimary
                onClicked: root.showSessionPopup()
            }
        }
    }
}
