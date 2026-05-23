// =========================================================
// DimArch — Session Popup
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: popupRoot

    property int maxVisible: 5
    property int itemHeight: Math.round(42 * root.uiScale)
    property int visibleCount: Math.min(sessionList.count, maxVisible)

    width:  Math.round(260 * root.uiScale)
    height: visibleCount * itemHeight + Math.round(12 * root.uiScale)

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
        verticalOffset: Math.round(6 * root.uiScale)
        radius: Math.round(20 * root.uiScale)
        samples: Math.round(20 * root.uiScale) * 2 + 1
        color: "#20000000"
        cached: false
    }

    Rectangle {
        id: popup

        anchors.fill: parent
        radius: Math.round(16 * root.uiScale)
        color: "#E6FFFFFF"
        border.color: "#99FFFFFF"
        border.width: 1
        clip: true

        ListView {
            id: sessionList

            anchors {
                fill: parent
                margins: Math.round(6 * root.uiScale)
            }

            clip: true
            model: sessionModel
            interactive: count > popupRoot.maxVisible
            boundsBehavior: Flickable.StopAtBounds

            // Custom scroll indicator — no QtQuick.Controls dependency
            Rectangle {
                visible: sessionList.count > popupRoot.maxVisible
                width: Math.round(3 * root.uiScale)
                height: sessionList.height * (popupRoot.maxVisible / sessionList.count)
                y: sessionList.contentY * (sessionList.height / sessionList.contentHeight)
                anchors.right: parent.right
                anchors.rightMargin: Math.round(3 * root.uiScale)
                radius: width / 2
                color: config.AccentGreen
                opacity: sessionList.moving ? 0.8 : 0.4

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            delegate: Rectangle {
                width: sessionList.width
                height: popupRoot.itemHeight
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
