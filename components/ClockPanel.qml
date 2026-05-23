// =========================================================
// DimArch — Clock Panel
// =========================================================

import QtQuick 2.15

Column {
    id: clockPanel

    spacing: Math.round(4 * root.uiScale)
    property date now: new Date()

    Text {
        anchors.right: parent.right
        text: Qt.formatTime(clockPanel.now, "HH:mm")
        font.family: config.FontFamily
        font.pixelSize: Math.round(parseInt(config.ClockSize) * root.uiScale)
        font.weight: Font.Light
        color: config.ClockColor
        style: Text.Raised
        styleColor: config.ClockShadow
        renderType: Text.NativeRendering
    }

    Text {
        anchors.right: parent.right
        text: Qt.formatDate(clockPanel.now, "dddd")
        font.family: config.FontFamily
        font.pixelSize: Math.round(parseInt(config.WeekdaySize) * root.uiScale)
        font.weight: Font.Medium
        color: config.ClockColor
        opacity: 0.92
        style: Text.Raised
        styleColor: config.ClockShadow
        renderType: Text.NativeRendering
    }

    Text {
        anchors.right: parent.right
        text: Qt.formatDate(clockPanel.now, "d MMMM")
        font.family: config.FontFamily
        font.pixelSize: Math.round(parseInt(config.DateSize) * root.uiScale)
        color: config.ClockColor
        opacity: 0.74
        style: Text.Raised
        styleColor: config.ClockShadow
        renderType: Text.NativeRendering
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockPanel.now = new Date()
    }
}
