// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../Base"

HListView {
    id: mainPaneList


    readonly property var originSource: window.mainPaneModelSource
    readonly property var collapseAccounts: window.uiState.collapseAccounts
    readonly property string filter: toolBar.roomFilter
    readonly property alias activateLimiter: activateLimiter

    onOriginSourceChanged: filterLimiter.restart()
    onFilterChanged: filterLimiter.restart()
    onCollapseAccountsChanged: filterLimiter.restart()


    function filterSource() {
        let show = []

        // Hide a harmless error when activating a RoomDelegate
        try { window.mainPaneModelSource } catch (err) { return }

        for (let i = 0;  i < window.mainPaneModelSource.length; i++) {
            let item = window.mainPaneModelSource[i]

            if (item.type === "Account" ||
                (filter ?
                 utils.filterMatches(filter, item.data.filter_string) :
                 ! window.uiState.collapseAccounts[item.user_id]))
            {
                if (filter && show.length && item.type === "Account" &&
                    show[show.length - 1].type === "Account" &&
                    ! utils.filterMatches(
                        filter, show[show.length - 1].data.filter_string)
                ) {
                    // If filter active, current and previous items are
                    // both accounts and previous account doesn't match filter,
                    // that means the previous account had no matching rooms.
                    show.pop()
                }

                show.push(item)
            }
        }

        let last = show[show.length - 1]
        if (show.length && filter && last.type === "Account" &&
            ! utils.filterMatches(filter, last.data.filter_string))
        {
            // If filter active, last item is an account and last item
            // doesn't match filter, that account had no matching rooms.
            show.pop()
        }

        model.source = show
    }

    function previous(activate=true) {
        decrementCurrentIndex()
        if (activate) activateLimiter.restart()
    }

    function next(activate=true) {
        incrementCurrentIndex()
        if (activate) activateLimiter.restart()
    }

    function activate() {
        currentItem.item.activated()
    }

    function accountSettings() {
        if (! currentItem) incrementCurrentIndex()

        pageLoader.showPage(
            "AccountSettings/AccountSettings",
            {userId: currentItem.item.delegateModel.user_id},
        )
    }

    function addNewChat() {
        if (! currentItem) incrementCurrentIndex()

        pageLoader.showPage(
            "AddChat/AddChat",
            {userId: currentItem.item.delegateModel.user_id},
        )
    }

    function toggleCollapseAccount() {
        if (filter) return

        if (! currentItem) incrementCurrentIndex()

        if (currentItem.item.delegateModel.type === "Account") {
            currentItem.item.toggleCollapse()
            return
        }

        for (let i = 0;  i < model.source.length; i++) {
            let item = model.source[i]

            if (item.type === "Account" && item.user_id ==
                currentItem.item.delegateModel.user_id)
            {
                currentIndex = i
                currentItem.item.toggleCollapse()
            }
        }
    }


    model: HListModel {
        keyField: "id"
        source: originSource
    }

    delegate: Loader {
        width: mainPaneList.width
        Component.onCompleted: setSource(
            model.type === "Account" ?
            "AccountDelegate.qml" : "RoomDelegate.qml",
            {view: mainPaneList}
        )
    }


    Timer {
        id: filterLimiter
        interval: 16
        onTriggered: filterSource()
    }

    Timer {
        id: activateLimiter
        interval: 300
        onTriggered: activate()
    }
}
