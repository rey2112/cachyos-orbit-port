// Orbit Neutral SDDM theme (Qt 6): date and large time at the top, the user
// and a frosted password pill at the bottom, session picker bottom-left,
// power actions bottom-right. Neutral graphite and white, no accent colour.
import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#111113"

    readonly property color foreground: "#f5f5f7"
    readonly property color muted: Qt.rgba(245 / 255, 245 / 255, 247 / 255, 0.65)
    readonly property string fontFamily: config.font ? config.font : "Inter"
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // Neutral graphite gradient, or the configured wallpaper dimmed under it.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1c1c1f" }
            GradientStop { position: 1.0; color: "#0b0b0d" }
        }
    }
    Image {
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        opacity: 0.55
        asynchronous: true
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.now, "dddd, d MMMM")
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: 22
            font.weight: Font.Medium
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.now, "HH:mm")
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: 132
            font.weight: Font.DemiBold
            font.letterSpacing: -3
        }
    }

    Column {
        id: loginColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.12
        spacing: 14

        // Initial in a soft circle stands in for an avatar.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72
            height: 72
            radius: 36
            color: Qt.rgba(1, 1, 1, 0.12)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: userField.text.length > 0 ? userField.text.charAt(0).toUpperCase() : "?"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: 30
                font.weight: Font.DemiBold
            }
        }

        // Editable user name, styled as plain centred text.
        TextField {
            id: userField
            anchors.horizontalCenter: parent.horizontalCenter
            width: 240
            text: userModel.lastUser
            horizontalAlignment: TextInput.AlignHCenter
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: 17
            font.weight: Font.DemiBold
            placeholderText: "User"
            placeholderTextColor: root.muted
            background: Item {}
            KeyNavigation.tab: passwordField
            onAccepted: passwordField.forceActiveFocus()
        }

        TextField {
            id: passwordField
            anchors.horizontalCenter: parent.horizontalCenter
            width: 260
            height: 40
            echoMode: TextInput.Password
            passwordCharacter: "•"
            horizontalAlignment: TextInput.AlignHCenter
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: 15
            placeholderText: "Enter Password"
            placeholderTextColor: root.muted
            leftPadding: 18
            rightPadding: 18
            background: Rectangle {
                radius: height / 2
                color: Qt.rgba(1, 1, 1, passwordField.activeFocus ? 0.14 : 0.10)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
            }
            KeyNavigation.backtab: userField
            onAccepted: {
                errorText.text = ""
                sddm.login(userField.text, passwordField.text, root.sessionIndex)
            }
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            color: "#df8a8a"
            font.family: root.fontFamily
            font.pixelSize: 13
            height: 16
        }
    }

    // Session picker, bottom-left.
    ComboBox {
        id: sessionBox
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        width: 200
        model: sessionModel
        textRole: "name"
        currentIndex: root.sessionIndex
        onActivated: root.sessionIndex = currentIndex
        font.family: root.fontFamily
        font.pixelSize: 13
        contentItem: Text {
            leftPadding: 14
            text: sessionBox.displayText
            color: root.muted
            font: sessionBox.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            implicitHeight: 32
            radius: 16
            color: Qt.rgba(1, 1, 1, sessionBox.hovered ? 0.12 : 0.07)
        }
    }

    // Power actions, bottom-right.
    component PowerButton: Button {
        id: powerButton
        font.family: root.fontFamily
        font.pixelSize: 13
        contentItem: Text {
            text: powerButton.text
            color: root.muted
            font: powerButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 92
            implicitHeight: 32
            radius: 16
            color: Qt.rgba(1, 1, 1, powerButton.hovered ? 0.12 : 0.07)
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 10

        PowerButton {
            text: "Sleep"
            visible: sddm.canSuspend
            onClicked: sddm.suspend()
        }
        PowerButton {
            text: "Restart"
            visible: sddm.canReboot
            onClicked: sddm.reboot()
        }
        PowerButton {
            text: "Shut Down"
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Incorrect password"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        if (userField.text.length > 0)
            passwordField.forceActiveFocus()
        else
            userField.forceActiveFocus()
    }
}
