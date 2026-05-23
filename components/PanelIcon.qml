// =========================================================
// DimArch — Power Panel Icon
// =========================================================

import QtQuick 2.15

Item {
    id: iconRoot

    width: 36
    height: 36

    property string symbol: ""
    property color baseColor: "#4B5563"
    property color hoverColor: "#1F2933"
    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: 11
        color: mouse.containsMouse ? "#45FFFFFF" : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        anchors.centerIn: parent
        text: iconRoot.symbol
        font.family: config.FontFamily
        font.pixelSize: 23
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
