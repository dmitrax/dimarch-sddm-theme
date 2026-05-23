// =========================================================
// DimArch — Session Popup
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: popupRoot

    width:  Math.round(260 * root.uiScale)
    height: Math.max(1, sessionList.count) * Math.round(42 * root.uiScale) + Math.round(12 * root.uiScale)

    Rectangle {
        id: shadowSource
        anchors.fill: popup
        radius: popup.radius
        visible: false
    }

    DropShadow {
        anchors.fill: shadowSource
        source: shadowSource
        horizontalOffset: 0
        verticalOffset: Math.round(10 * root.uiScale)
        radius: Math.round(30 * root.uiScale)
        samples: 44
        color: "#24000000"
        cached: true
    }

    Rectangle {
        id: popup

        anchors.fill: parent
        radius: Math.round(16 * root.uiScale)
        color: "#E6FFFFFF"
        border.color: "#99FFFFFF"
        border.width: 1

        ListView {
            id: sessionList

            anchors {
                fill: parent
                margins: Math.round(6 * root.uiScale)
            }

            clip: true
            model: sessionModel
            interactive: contentHeight > height

            delegate: Rectangle {
                width: sessionList.width
                height: Math.round(42 * root.uiScale)
                radius: Math.round(12 * root.uiScale)

                property bool selected: index === root.selectedSessionIndex

                color: selected
                    ? "#447FB89E"
                    : (sessionMouseArea.containsMouse ? "#2E7FB89E" : "transparent")

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: Math.round(16 * root.uiScale)
                        right: selectedMark.left
                        rightMargin: Math.round(10 * root.uiScale)
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.name
                    elide: Text.ElideRight
                    font.family: config.FontFamily
                    font.pixelSize: Math.round(14 * root.uiScale)
                    font.weight: selected ? Font.Medium : Font.Normal
                    color: config.TextPrimary
                    renderType: Text.NativeRendering
                }

                Text {
                    id: selectedMark
                    anchors {
                        right: parent.right
                        rightMargin: Math.round(14 * root.uiScale)
                        verticalCenter: parent.verticalCenter
                    }
                    text: "✓"
                    visible: selected
                    font.family: config.FontFamily
                    font.pixelSize: Math.round(14 * root.uiScale)
                    font.weight: Font.Medium
                    color: config.AccentGreen
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: sessionMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.setSession(index, model.name)
                        sessionPopup.visible = false
                    }
                }
            }
        }
    }
}
