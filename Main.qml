// =========================================================
// DimArch SDDM Theme 1.3.1
// Theme ID: dimarch
// Qt 5.x compatible
// =========================================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0
import "components"

Rectangle {
    id: root

    width: parent ? parent.width : 1920
    height: parent ? parent.height : 1080
    color: config.FallbackBg

    // ── Primary monitor zone ──────────────────────────────
    // If PrimaryWidth/Height are 0, fall back to full screen.
    // Use physical pixel values from your display configuration.

    property int primaryX:      parseInt(config.PrimaryX)      > 0 ? parseInt(config.PrimaryX)      : 0
    property int primaryY:      parseInt(config.PrimaryY)      > 0 ? parseInt(config.PrimaryY)      : 0
    property int primaryWidth:  parseInt(config.PrimaryWidth)  > 0 ? parseInt(config.PrimaryWidth)  : root.width
    property int primaryHeight: parseInt(config.PrimaryHeight) > 0 ? parseInt(config.PrimaryHeight) : root.height

    // ── Auto UI scale based on primary monitor height ─────
    // Base sizes in theme.conf are defined for 1080p.
    // UiScale=0 in theme.conf means auto-detect.

    property real uiScale: {
        var manual = parseFloat(config.UiScale)
        if (manual > 0) return manual          // manual override

        var h = primaryHeight
        if (h >= 2160) return 1.5             // 4K
        if (h >= 1440) return 1.2             // 1440p
        if (h >= 1080) return 1.0             // 1080p
        return 0.85                            // below 1080p
    }

    // ── Session state ─────────────────────────────────────

    property int selectedSessionIndex: 0
    property string currentSessionName: ""

    function setSession(sessionIndex, sessionName) {
        selectedSessionIndex = sessionIndex
        currentSessionName = sessionName
    }

    function doLogin(password) {
        if (password.length === 0) {
            loginCard.showError(config.ErrorEmptyPassword)
            return
        }
        sddm.login(userModel.lastUser, password, selectedSessionIndex)
    }

    function showSessionPopup() {
        sessionPopup.visible = !sessionPopup.visible
    }

    // Initialize visible session name
    Repeater {
        model: sessionModel

        delegate: Item {
            Component.onCompleted: {
                if (sessionModel.lastIndex >= 0) {
                    root.selectedSessionIndex = sessionModel.lastIndex
                }
                if (index === root.selectedSessionIndex) {
                    root.currentSessionName = model.name
                }
                if (root.currentSessionName.length === 0 && index === 0) {
                    root.currentSessionName = model.name
                    root.selectedSessionIndex = 0
                }
            }
        }
    }

    // ── Background (covers full virtual desktop) ──────────

    Image {
        id: bgImage
        anchors.fill: parent
        source: config.BgSource
        fillMode: Image.PreserveAspectCrop
        clip: true
        asynchronous: false
        cache: false
    }

    Rectangle {
        anchors.fill: parent
        color: config.OverlayColor
        opacity: parseFloat(config.OverlayOpacity)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#18000000" }
            GradientStop { position: 0.35; color: "#00000000" }
            GradientStop { position: 1.00; color: "#10000000" }
        }
    }

    // ── Primary zone — all UI lives here ─────────────────

    Item {
        id: primaryZone
        x: root.primaryX
        y: root.primaryY
        width: root.primaryWidth
        height: root.primaryHeight

        ClockPanel {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: Math.round(72 * root.uiScale)
                rightMargin: Math.round(86 * root.uiScale)
            }
        }

        Column {
            id: loginStack
            anchors.centerIn: parent
            spacing: Math.round(18 * root.uiScale)

            LoginCard {
                id: loginCard
                sessionName: root.currentSessionName
            }

            PowerPanel {
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        SessionPopup {
            id: sessionPopup
            visible: false
            z: 100
            anchors.horizontalCenter: loginStack.horizontalCenter
            y: loginStack.y + loginCard.height + Math.round(10 * root.uiScale)
        }
    }

    // ── SDDM signals ──────────────────────────────────────

    Connections {
        target: sddm

        function onLoginFailed() {
            loginCard.onLoginFailed()
        }

        function onLoginSucceeded() {
            loginCard.onLoginSucceeded()
        }
    }
}
