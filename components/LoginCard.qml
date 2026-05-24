// =========================================================
// DimArch — Login Card
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: loginCardRoot

    width: Math.round(parseInt(config.CardWidth) * root.uiScale)

    // Auto-height: 0 = automatic, >0 = fixed
    property int fixedHeight: Math.round(parseInt(config.CardHeight) * root.uiScale)
    height: fixedHeight > 0
        ? fixedHeight
        : loginCardRoot.contentTopMargin
          + content.implicitHeight
          + loginCardRoot.footerGap
          + loginCardRoot.footerH
          + loginCardRoot.bottomPad

    property int pad:              Math.round(parseInt(config.CardPadding)          * root.uiScale)
    property int gap:              Math.round(parseInt(config.CardSpacing)          * root.uiScale)
    property int contentTopMargin: Math.round(parseInt(config.CardContentTopMargin) * root.uiScale)
    property int footerGap:        Math.round(parseInt(config.CardFooterGap)        * root.uiScale)
    property int bottomPad:        Math.round(parseInt(config.CardBottomPadding)    * root.uiScale)
    property int footerH:          Math.round(parseInt(config.FooterHeight)         * root.uiScale)
    property int footerIconSpacing:Math.round(parseInt(config.FooterIconSpacing)    * root.uiScale)
    property real formWidthRatio:  parseFloat(config.FormWidthRatio)

    property string sessionName: ""

    // ── Glass surface + shadow ────────────────────────────
    Rectangle {
        id: glassSurface
        anchors.fill: parent
        radius: Math.round(parseInt(config.CardRadius) * root.uiScale)
        color: config.CardBg
        opacity: parseFloat(config.CardBgOpacity)
        antialiasing: true

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: Math.round(10 * root.uiScale)
            radius: Math.round(34 * root.uiScale)
            samples: Math.round(34 * root.uiScale) * 2 + 1
            color: "#33000000"
            cached: false
        }
    }

    // Top highlight
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
        height: parent.height * 0.45
        radius: Math.round(parseInt(config.CardRadius) * root.uiScale)
        opacity: parseFloat(config.CardTopHighlightOpacity)
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#FFFFFFFF" }
            GradientStop { position: 0.55; color: "#44FFFFFF" }
            GradientStop { position: 1.00; color: "#00FFFFFF" }
        }
    }

    // Outer border
    Rectangle {
        anchors.fill: parent
        radius: Math.round(parseInt(config.CardRadius) * root.uiScale)
        color: "transparent"
        border.color: config.CardBorder
        border.width: 1
        opacity: parseFloat(config.CardBorderOpacity)
        antialiasing: true
    }

    // Inner glow
    Rectangle {
        anchors { fill: parent; margins: Math.round(1 * root.uiScale) }
        radius: Math.round(parseInt(config.CardRadius) * root.uiScale) - 1
        color: "transparent"
        border.color: "#66FFFFFF"
        border.width: 1
        opacity: 0.45
        antialiasing: true
    }

    // ── Main content ──────────────────────────────────────
    Column {
        id: content
        anchors {
            top: parent.top
            topMargin: loginCardRoot.contentTopMargin
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - loginCardRoot.pad * 2
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
            color: config.TextPrimary
            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: config.LabelSession + " " + loginCardRoot.sessionName
            font.family: config.FontFamily
            font.pixelSize: Math.round(13 * root.uiScale)
            color: config.TextPrimary
            opacity: 0.6
            visible: loginCardRoot.sessionName.length > 0
            renderType: Text.NativeRendering
        }

        // Spacer between info and form
        Item { width: 1; height: Math.round(4 * root.uiScale) }

        Rectangle {
            id: passwordBox
            width: Math.round(parent.width * loginCardRoot.formWidthRatio)
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.round(parseInt(config.InputHeight) * root.uiScale)
            radius: Math.round(parseInt(config.InputRadius) * root.uiScale)
            color: config.InputBg
            border.color: passwordField.activeFocus ? config.InputBorderFocus : config.InputBorder
            border.width: passwordField.activeFocus ? 1.8 : 1.2
            Behavior on border.color { ColorAnimation { duration: 120 } }

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
                anchors { fill: parent; leftMargin: Math.round(20 * root.uiScale); rightMargin: Math.round(20 * root.uiScale) }
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
            width: Math.round(parent.width * loginCardRoot.formWidthRatio)
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.round(parseInt(config.ButtonHeight) * root.uiScale)
            radius: Math.round(parseInt(config.ButtonRadius) * root.uiScale)
            color: loginMouseArea.pressed ? config.ButtonPressed
                 : loginMouseArea.containsMouse ? config.ButtonHover : config.ButtonBg
            Behavior on color { ColorAnimation { duration: 120 } }

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
            height: text.length > 0 ? Math.round(18 * root.uiScale) : 0
            horizontalAlignment: Text.AlignHCenter
            text: ""
            font.family: config.FontFamily
            font.pixelSize: Math.round(13 * root.uiScale)
            color: config.DangerRed
            opacity: text.length > 0 ? 1 : 0
            renderType: Text.NativeRendering
            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on height  { NumberAnimation { duration: 120 } }
        }
    }

    // ── Footer separator ──────────────────────────────────
    // (removed — footer is now a pill, no full-width separator needed)

    // ── Footer ────────────────────────────────────────────
    Rectangle {
        id: footer
        width: Math.round(parent.width * loginCardRoot.formWidthRatio)
        anchors {
            top: content.bottom
            topMargin: loginCardRoot.footerGap
            horizontalCenter: parent.horizontalCenter
        }
        height: loginCardRoot.footerH
        radius: Math.round(parseInt(config.InputRadius) * root.uiScale)
        color: "#FFFFFF"
        opacity: 0.45
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: footer.verticalCenter
        }
        spacing: loginCardRoot.footerIconSpacing

        PanelIcon { symbol: "⏻"; hoverColor: config.DangerRed;   onClicked: sddm.powerOff() }
        PanelIcon { symbol: "↻"; hoverColor: config.TextPrimary; onClicked: sddm.reboot() }
        PanelIcon { symbol: "▦"; hoverColor: config.TextPrimary; onClicked: root.showSessionPopup() }
    }

    function showError(message) { errorMessage.text = message }
    function onLoginFailed() {
        passwordField.text = ""
        passwordField.focus = true
        showError(config.ErrorWrongPassword)
    }
    function onLoginSucceeded() { errorMessage.text = "" }
}
