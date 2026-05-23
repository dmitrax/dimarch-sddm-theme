// =========================================================
// DimArch — Session Popup
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: popupRoot

    width: 260
    height: Math.max(1, sessionList.count) * 42 + 12

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
        verticalOffset: 10
        radius: 30
        samples: 44
        color: "#24000000"
        cached: true
    }

    Rectangle {
        id: popup

        anchors.fill: parent
        radius: 16
        color: "#E6FFFFFF"
        border.color: "#99FFFFFF"
        border.width: 1

        ListView {
            id: sessionList

            anchors {
                fill: parent
                margins: 6
            }

            clip: true
            model: sessionModel
            interactive: contentHeight > height

            delegate: Rectangle {
                width: sessionList.width
                height: 42
                radius: 12

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
                        leftMargin: 16
                        right: selectedMark.left
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    text: model.name
                    elide: Text.ElideRight
                    font.family: config.FontFamily
                    font.pixelSize: 14
                    font.weight: selected ? Font.Medium : Font.Normal
                    color: config.TextPrimary
                    renderType: Text.NativeRendering
                }

                Text {
                    id: selectedMark

                    anchors {
                        right: parent.right
                        rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }

                    text: "✓"
                    visible: selected
                    font.family: config.FontFamily
                    font.pixelSize: 14
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
