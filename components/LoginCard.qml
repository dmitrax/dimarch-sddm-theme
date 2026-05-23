// =========================================================
// DimArch — Login Card
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: loginCardRoot

    width: parseInt(config.CardWidth)
    height: parseInt(config.CardHeight)

    property int pad: parseInt(config.CardPadding)
    property int gap: parseInt(config.CardSpacing)
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
        verticalOffset: 16
        radius: 48
        samples: 64
        color: "#26000000"
        cached: true
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: parseInt(config.CardRadius)
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
                size: parseInt(config.AvatarSize)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.WelcomePrefix + " " + config.SystemName
                font.family: config.FontFamily
                font.pixelSize: 25
                font.weight: Font.DemiBold
                color: config.TextPrimary
                renderType: Text.NativeRendering
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: userModel.lastUser
                font.family: config.FontFamily
                font.pixelSize: 16
                font.weight: Font.Medium
                color: config.TextSecondary
                renderType: Text.NativeRendering
            }

            Rectangle {
                width: parent.width
                height: 28
                radius: 14
                color: "#3DFFFFFF"
                border.color: "#66FFFFFF"
                border.width: 1
                visible: loginCardRoot.sessionName.length > 0

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 24
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    text: config.LabelSession + " " + loginCardRoot.sessionName
                    font.family: config.FontFamily
                    font.pixelSize: 13
                    color: config.TextSecondary
                    renderType: Text.NativeRendering
                }
            }

            Rectangle {
                id: passwordBox
                width: parent.width
                height: parseInt(config.InputHeight)
                radius: parseInt(config.InputRadius)
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
                    font.pixelSize: 16
                    color: config.InputPlaceholder
                    visible: passwordField.text.length === 0 && !passwordField.activeFocus
                    renderType: Text.NativeRendering
                }

                TextInput {
                    id: passwordField

                    anchors {
                        fill: parent
                        leftMargin: 20
                        rightMargin: 20
                    }

                    focus: true
                    echoMode: TextInput.Password
                    passwordCharacter: "●"

                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    font.family: config.FontFamily
                    font.pixelSize: 18
                    color: config.InputText
                    selectionColor: config.AccentGreen
                    selectedTextColor: "#FFFFFF"
                    clip: true

                    Keys.onReturnPressed: root.doLogin(passwordField.text)
                    Keys.onEnterPressed: root.doLogin(passwordField.text)
                }
            }

            Rectangle {
                id: loginButton

                width: parent.width
                height: parseInt(config.ButtonHeight)
                radius: parseInt(config.ButtonRadius)
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
                    font.pixelSize: 16
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
                height: 18
                horizontalAlignment: Text.AlignHCenter
                text: ""
                font.family: config.FontFamily
                font.pixelSize: 13
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
