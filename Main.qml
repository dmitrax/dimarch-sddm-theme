// =========================================================
// DimArch SDDM Theme 1.0.0
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

    // Initialize visible session name without writing to read-only sessionModel.lastIndex.
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

    ClockPanel {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 72
            rightMargin: 86
        }
    }

    Column {
        id: loginStack
        anchors.centerIn: parent
        spacing: 18

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
        y: loginStack.y + loginCard.height + 10
    }

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
