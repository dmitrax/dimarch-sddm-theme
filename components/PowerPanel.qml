// =========================================================
// DimArch — Power Panel
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: powerRoot

    width:  Math.round(236 * root.uiScale)
    height: Math.round(56  * root.uiScale)

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
        verticalOffset: Math.round(4 * root.uiScale)
        radius: Math.round(16 * root.uiScale)
        samples: Math.round(16 * root.uiScale) * 2 + 1
        color: "#18000000"
        cached: false
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: Math.round(19 * root.uiScale)
        color: "#A8FFFFFF"
        border.color: "#99FFFFFF"
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: Math.round(36 * root.uiScale)

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
