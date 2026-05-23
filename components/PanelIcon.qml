// =========================================================
// DimArch — Power Panel Icon
// =========================================================

import QtQuick 2.15

Item {
    id: iconRoot

    width:  Math.round(36 * root.uiScale)
    height: Math.round(36 * root.uiScale)

    property string symbol: ""
    property color baseColor: "#4B5563"
    property color hoverColor: "#1F2933"
    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: Math.round(11 * root.uiScale)
        color: mouse.containsMouse ? "#45FFFFFF" : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        anchors.centerIn: parent
        text: iconRoot.symbol
        font.family: config.FontFamily
        font.pixelSize: Math.round(23 * root.uiScale)
        font.weight: Font.Medium
        color: mouse.containsMouse ? iconRoot.hoverColor : iconRoot.baseColor
        renderType: Text.NativeRendering

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: iconRoot.clicked()
    }
}
