// =========================================================
// DimArch — Login Card
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: loginCardRoot

    width:  Math.round(parseInt(config.CardWidth)  * root.uiScale)
    height: Math.round(parseInt(config.CardHeight) * root.uiScale)

    property int pad: Math.round(parseInt(config.CardPadding) * root.uiScale)
    property int gap: Math.round(parseInt(config.CardSpacing) * root.uiScale)
    property string sessionName: ""

    Rectangle {
        id: shadowSource
        anchors.fill: card
        radius: card.radius
        visible: false
    }

    DropShadow {
        anchors.fill: shadowSource
        source: shadowSource
        horizontalOffset: 0
        verticalOffset: Math.round(8 * root.uiScale)
        radius: Math.round(32 * root.uiScale)
        samples: Math.round(32 * root.uiScale) * 2 + 1
        color: "#1C000000"
        cached: false
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Math.round(parseInt(config.CardRadius) * root.uiScale)
        color: config.CardBg
        border.color: config.CardBorder
        border.width: 1

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 1
            }
            height: parent.height * 0.46
            radius: parent.radius
            opacity: 0.20
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FFFFFFFF" }
                GradientStop { position: 1.0; color: "#00FFFFFF" }
            }
        }

        Column {
            id: content
            anchors {
                fill: parent
                margins: loginCardRoot.pad
            }
            spacing: loginCardRoot.gap

            UserAvatar {
                anchors.horizontalCenter: parent.horizontalCenter
                size: Math.round(parseInt(config.AvatarSize) * root.uiScale)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.WelcomePrefix + " " + config.SystemName
                font.family: config.FontFamily
                font.pixelSize: Math.round(25 * root.uiScale)
                font.weight: Font.DemiBold
                color: config.TextPrimary
                renderType: Text.NativeRendering
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: userModel.lastUser
                font.family: config.FontFamily
                font.pixelSize: Math.round(16 * root.uiScale)
                font.weight: Font.Medium
                color: config.TextSecondary
                renderType: Text.NativeRendering
            }

            Rectangle {
                width: parent.width
                height: Math.round(28 * root.uiScale)
                radius: Math.round(14 * root.uiScale)
                color: "#3DFFFFFF"
                border.color: "#66FFFFFF"
                border.width: 1
                visible: loginCardRoot.sessionName.length > 0

                Text {
                    anchors.centerIn: parent
                    width: parent.width - Math.round(24 * root.uiScale)
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    text: config.LabelSession + " " + loginCardRoot.sessionName
                    font.family: config.FontFamily
                    font.pixelSize: Math.round(13 * root.uiScale)
                    color: config.TextSecondary
                    renderType: Text.NativeRendering
                }
            }

            Rectangle {
                id: passwordBox
                width: parent.width
                height: Math.round(parseInt(config.InputHeight) * root.uiScale)
                radius: Math.round(parseInt(config.InputRadius) * root.uiScale)
                color: config.InputBg
                border.color: passwordField.activeFocus ? config.InputBorderFocus : config.InputBorder
                border.width: passwordField.activeFocus ? 1.8 : 1.2

                Behavior on border.color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: config.LabelPassword
                    font.family: config.FontFamily
                    font.pixelSize: Math.round(16 * root.uiScale)
                    color: config.InputPlaceholder
                    visible: passwordField.text.length === 0 && !passwordField.activeFocus
                    renderType: Text.NativeRendering
                }

                TextInput {
                    id: passwordField

                    anchors {
                        fill: parent
                        leftMargin: Math.round(20 * root.uiScale)
                        rightMargin: Math.round(20 * root.uiScale)
                    }

                    focus: true
                    echoMode: TextInput.Password
                    passwordCharacter: "●"

                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    font.family: config.FontFamily
                    font.pixelSize: Math.round(18 * root.uiScale)
                    color: config.InputText
                    selectionColor: config.AccentGreen
                    selectedTextColor: "#FFFFFF"
                    clip: true

                    Keys.onReturnPressed: root.doLogin(passwordField.text)
                    Keys.onEnterPressed:  root.doLogin(passwordField.text)
                }
            }

            Rectangle {
                id: loginButton

                width: parent.width
                height: Math.round(parseInt(config.ButtonHeight) * root.uiScale)
                radius: Math.round(parseInt(config.ButtonRadius) * root.uiScale)
                color: loginMouseArea.pressed
                    ? config.ButtonPressed
                    : (loginMouseArea.containsMouse ? config.ButtonHover : config.ButtonBg)

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: config.LabelSignIn
                    font.family: config.FontFamily
                    font.pixelSize: Math.round(16 * root.uiScale)
                    font.weight: Font.Medium
                    color: config.ButtonText
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: loginMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.doLogin(passwordField.text)
                }
            }

            Text {
                id: errorMessage

                width: parent.width
                height: Math.round(18 * root.uiScale)
                horizontalAlignment: Text.AlignHCenter
                text: ""
                font.family: config.FontFamily
                font.pixelSize: Math.round(13 * root.uiScale)
                color: config.DangerRed
                opacity: text.length > 0 ? 1 : 0
                renderType: Text.NativeRendering

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }
        }
    }

    function showError(message) {
        errorMessage.text = message
    }

    function onLoginFailed() {
        passwordField.text = ""
        passwordField.focus = true
        showError(config.ErrorWrongPassword)
    }

    function onLoginSucceeded() {
        errorMessage.text = ""
    }
}
