// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../../Base"
import "../../Base/ButtonLayout"
import "../../Base/HTile"

HTile {
    id: device


    property HListView view


    backgroundColor: "transparent"
    compact: false

    leftPadding: theme.spacing * 2
    rightPadding: 0

    contentItem: ContentRow {
        tile: device
        spacing: 0

        HCheckBox {
            id: checkBox
            checked: view.checked[model.id] || false
            onClicked: view.toggleCheck(model.index)
        }

        HColumnLayout {
            Layout.leftMargin: theme.spacing

            HRowLayout {
                spacing: theme.spacing

                TitleLabel {
                    text: model.display_name || qsTr("Unnamed")
                }

                TitleRightInfoLabel {
                    tile: device
                    text: utils.smartFormatDate(model.last_seen_date)
                }
            }

            SubtitleLabel {
                tile: device
                font.family: theme.fontFamily.mono
                text:
                    model.last_seen_ip ?
                    model.id + " " + model.last_seen_ip :
                    model.id
            }
        }

        HButton {
            icon.name: "device-action-menu"
            toolTip.text: qsTr("Rename, verify or sign out")
            backgroundColor: "transparent"
            onClicked: contextMenuLoader.active = true

            Layout.fillHeight: true
        }
    }

    contextMenu: HMenu {
        id: actionMenu
        implicitWidth: Math.min(320 * theme.uiScale, window.width)
        onOpened: nameField.forceActiveFocus()

        HLabeledItem {
            width: parent.width
            label.topPadding: theme.spacing / 2
            label.text: qsTr("Public display name:")
            label.horizontalAlignment: Qt.AlignHCenter

            HTextField {
                id: nameField
                width: parent.width
                defaultText: model.display_name
                horizontalAlignment: Qt.AlignHCenter
            }
        }

        HMenuSeparator {}

        HLabeledItem {
            width: parent.width
            label.text: qsTr("Actions:")
            label.horizontalAlignment: Qt.AlignHCenter

            ButtonLayout {
                width: parent.width

                ApplyButton {
                    enabled:
                        model.type !== "current" && model.type !== "verified"
                    text: qsTr("Verify")
                    icon.name: "device-verify"
                }

                CancelButton {
                    text: qsTr("Sign out")
                    icon.name: "device-delete"
                }
            }
        }
    }

    onLeftClicked: checkBox.clicked()
}