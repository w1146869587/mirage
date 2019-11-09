import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../../Base"
import "../../utils.js" as Utils

HBox {
    id: addChatBox
    clickButtonOnEnter: "apply"

    onFocusChanged: userField.forceActiveFocus()

    buttonModel: [
        { name: "apply", text: qsTr("Start chat"), iconName: "join",
          enabled: Boolean(userField.text), },
        { name: "cancel", text: qsTr("Cancel"), iconName: "cancel" },
    ]

    buttonCallbacks: ({
        apply: button => {
            button.loading    = true
            errorMessage.text = ""

            let args = [userField.text]

            py.callClientCoro(userId, "new_direct_chat", args, roomId => {
                button.loading    = false
                errorMessage.text = ""
                pageLoader.showRoom(userId, roomId)

            }, (type, args) => {
                button.loading = false

                let txt = qsTr("Unknown error - %1: %2").arg(type).arg(args)

                if (type === "InvalidUserInContext")
                    txt = qsTr("You cannot invite yourself!")

                if (type === "UserNotFound")
                    txt = qsTr("This user does not exist.")

                errorMessage.text = txt
            })
        },

        cancel: button => {
            userField.text    = ""
            errorMessage.text = ""
            pageLoader.showPrevious()
        }
    })


    readonly property string userId: addChatPage.userId


    HTextField {
        id: userField
        placeholderText: qsTr("User ID (e.g. @john:matrix.org)")
        error: Boolean(errorMessage.text)

        Layout.fillWidth: true
    }

    HLabel {
        id: errorMessage
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        color: theme.colors.errorText

        visible: Layout.maximumHeight > 0
        Layout.maximumHeight: text ? implicitHeight : 0
        Behavior on Layout.maximumHeight { HNumberAnimation {} }

        Layout.fillWidth: true
    }
}