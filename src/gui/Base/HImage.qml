import QtQuick 2.12

Image {
    id: image
    autoTransform: true
    asynchronous: true
    fillMode: Image.PreserveAspectFit

    cache: ! (animate && animated) &&
           (sourceSize.width + sourceSize.height) <= 512


    property bool broken: false
    property bool animate: true
    property bool animated: utils.urlExtension(image.source) === "gif"

    property alias showProgressBar: progressBarLoader.active
    property bool inderterminateProgressBar: false


    Component {
        id: animatedImageComponent

        AnimatedImage {
            id: animatedImage
            source: image.source
            autoTransform: image.autoTransform
            asynchronous: image.asynchronous
            fillMode: image.fillMode
            mirror: image.mirror
            mipmap: image.mipmap
            smooth: image.smooth
            horizontalAlignment: image.horizontalAlignment
            verticalAlignment: image.verticalAlignment

            // Online GIFs won't be able to loop if cache is set to false,
            // but caching GIFs is expansive.
            cache: ! Qt.resolvedUrl(source).startsWith("file://")
            paused: ! visible || window.hidden || userPaused

            property bool userPaused: ! window.settings.media.autoPlayGIF

            TapHandler {
                onTapped: parent.userPaused = ! parent.userPaused
            }

            HIcon {
                anchors.centerIn: parent
                svgName: "play-overlay"
                colorize: "transparent"
                dimension: Math.min(
                    parent.width - theme.spacing * 2,
                    parent.height - theme.spacing * 2,
                    theme.controls.image.maxPauseIndicatorSize,
                )
                scale: parent.status === Image.Ready && parent.paused ? 1 : 0

                Behavior on scale { HNumberAnimation { overshoot: 4 } }
            }
        }
    }

    HLoader {
        anchors.fill: parent
        sourceComponent: animate && animated ? animatedImageComponent : null
    }

    HLoader {
        id: progressBarLoader
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.5
        height: width
        active: image.status === Image.Loading

        sourceComponent: HCircleProgressBar {
            id: progressBar
            value: image.progress
            text: Math.round(value * 100) + "%"

            Behavior on value { HNumberAnimation { factor: 2 } }
        }
    }

    HIcon {
        anchors.centerIn: parent
        visible: broken || image.status === Image.Error
        svgName: "broken-image"
        colorize: theme.colors.negativeBackground
    }
}