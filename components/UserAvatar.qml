// =========================================================
// DimArch — User Avatar
// Priority:
// 1. /home/<user>/.face.icon
// 2. /home/<user>/.face
// 3. config.ThemeAvatar, if set
// 4. DA fallback
// =========================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: avatarRoot

    property int size: 86
    property string userName: userModel.lastUser && userModel.lastUser.length > 0 ? userModel.lastUser : ""

    width: size
    height: size

    property string faceIcon: userName.length > 0 ? "file:///home/" + userName + "/.face.icon" : ""
    property string face: userName.length > 0 ? "file:///home/" + userName + "/.face" : ""
    property string themeAvatar: config.ThemeAvatar && config.ThemeAvatar.length > 0 ? config.ThemeAvatar : ""

    Rectangle {
        id: avatarCircle
        anchors.fill: parent
        radius: width / 2
        color: "#66FFFFFF"
        border.color: "#B8FFFFFF"
        border.width: 1
    }

    Image {
        id: avatarFaceIcon
        anchors.fill: parent
        source: avatarRoot.faceIcon
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: false
        visible: status === Image.Ready
        smooth: true
    }

    Image {
        id: avatarFace
        anchors.fill: parent
        source: avatarRoot.face
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: false
        visible: !avatarFaceIcon.visible && status === Image.Ready
        smooth: true
    }

    Image {
        id: avatarTheme
        anchors.fill: parent
        source: avatarRoot.themeAvatar
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: false
        visible: !avatarFaceIcon.visible && !avatarFace.visible && status === Image.Ready
        smooth: true
    }

    OpacityMask {
        anchors.fill: parent
        source: avatarFaceIcon.visible ? avatarFaceIcon : (avatarFace.visible ? avatarFace : avatarTheme)
        maskSource: avatarCircle
        visible: avatarFaceIcon.visible || avatarFace.visible || avatarTheme.visible
    }

    Text {
        anchors.centerIn: parent
        text: config.AvatarMonogram
        visible: !(avatarFaceIcon.visible || avatarFace.visible || avatarTheme.visible)
        font.family: config.FontFamily
        font.pixelSize: 30
        font.weight: Font.DemiBold
        color: config.AccentGreen
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: "#CCFFFFFF"
        border.width: 1
    }
}
