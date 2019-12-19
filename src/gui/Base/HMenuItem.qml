// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.12

MenuItem {
    id: menuItem
    spacing: theme.spacing
    leftPadding: spacing
    rightPadding: leftPadding
    topPadding: spacing / 1.75
    bottomPadding: topPadding
    height: visible ? implicitHeight : 0


    readonly property alias iconItem: contentItem.icon
    readonly property alias label: contentItem.label


    background: HButtonBackground {
        button: menuItem
        buttonTheme: theme.controls.menuItem
    }

    contentItem: HButtonContent {
        id: contentItem
        button: menuItem
        buttonTheme: theme.controls.menuItem
        label.horizontalAlignment: Label.AlignLeft
    }
}
