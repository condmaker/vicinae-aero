import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

Window {
    id: root
    property int shadowPadding: 0

    property int cornerRadius: Config.borderRounding
    property bool blurEnabled: Config.blurEnabled
    property bool shadowEnabled: shadowPadding > 0
    property bool nativeChrome: false
    property bool autoPlaceOnShow: true

    signal aboutToShow
    signal shown

    readonly property int _w: launcher.overrideWidth || Config.windowWidth
    readonly property int _h: launcher.overrideHeight || Config.windowHeight
    readonly property int _contentH: launcher.compacted ? 60 + 2 * Config.borderWidth : _h

    width: _w + 2 * shadowPadding
    height: _h + 2 * shadowPadding
    minimumWidth: _w + 2 * shadowPadding
    maximumWidth: _w + 2 * shadowPadding
    minimumHeight: _h + 2 * shadowPadding
    maximumHeight: _h + 2 * shadowPadding
    title: "Vicinae Launcher"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    WindowMaterial.enabled: root.blurEnabled && !root.nativeChrome
    WindowMaterial.radius: root.cornerRadius
    WindowMaterial.region: Qt.rect(shadowPadding, shadowPadding, _w, launcher.compacted ? _contentH : _h)

    Item {
        id: shadowMask
        width: root.width
        height: root.height
        visible: false
        layer.enabled: true

        Rectangle {
            x: root.shadowPadding
            y: root.shadowPadding
            width: _w
            height: _contentH
            radius: Config.borderRounding
            color: "white"
        }
    }

    Item {
        id: shadowCaster
        anchors.fill: parent
        visible: root.shadowEnabled && !root.nativeChrome

        Rectangle {
            x: root.shadowPadding
            y: root.shadowPadding
            width: _w
            height: _contentH
            radius: root.cornerRadius
            color: "black"
        }

        layer.enabled: root.shadowEnabled && !root.nativeChrome
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            shadowEnabled: true
            shadowBlur: 0.5
            shadowVerticalOffset: 3
            shadowColor: Qt.rgba(0, 0, 0, 0.3)
            maskEnabled: true
            maskInverted: true
            maskSource: shadowMask
        }
    }

    Item {
        id: content
        x: root.shadowPadding
        y: root.shadowPadding
        width: _w
        height: _h

        Item {
            visible: !launcher.compacted && !launcher.hasOverlay && launcher.statusBarVisible
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: footer.height + Config.borderWidth
            clip: true

            Rectangle {
                width: _w
                height: _h
                anchors.bottom: parent.bottom
                radius: root.cornerRadius
                color: Qt.rgba(Theme.statusBarBackground.r, Theme.statusBarBackground.g, Theme.statusBarBackground.b, Config.windowOpacity)
            }
        }

        ColumnLayout {
            id: mainCol

            anchors.fill: parent
            anchors.margins: Config.borderWidth
            anchors.top: parent.top
            spacing: 4

            SearchBar {
                id: searchBar

                width: _w
                height: 60 + 2 * Config.borderWidth
                radius: root.cornerRadius
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignTop
                enabled: !launcher.alertModel.visible

                gradient: StapleGradient {}

                border {
                    color: "#FF000000"
                    pixelAligned: true
                    width: 1
                }
            }

            HorizontalLoadingBar {
                Layout.fillWidth: true
                implicitHeight: launcher.searchVisible ? 1 : 0
                visible: launcher.searchVisible && !launcher.compacted
                loading: launcher.isLoading
            }

            Rectangle {
                id: contentArea

                opacity: !launcher.compacted ? 1 : 0
                objectName: "contentArea"
                radius: root.cornerRadius

                Layout.fillWidth: true
                Layout.fillHeight: true
                
                gradient: StapleGradient {}

                StackView {
                    id: commandStack
                    anchors.fill: parent
                }

                border {
                    color: "#61000000"
                    pixelAligned: true
                    width: 1
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Footer {
                id: footer
                opacity: !launcher.compacted && launcher.statusBarVisible ? 1 : 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 40 : 0

                gradient: StapleGradient {}

                border {
                    color: "#61000000"
                    pixelAligned: true
                    width: 1
                }
            }
        }

        Loader {
            id: overlayLoader
            anchors.fill: parent
            anchors.margins: Config.borderWidth
            visible: launcher.hasOverlay

            onLoaded: if (item)
                item.forceActiveFocus()
        }

        ActionPanelPopover {
            id: actionPanelPopover
            parent: footer
            controller: actionPanel
            maxHeight: Math.round(root.height * 0.6)
        }

        ActionPanelPopover {
            id: footerMenuPopover
            parent: footer
            controller: footerPanel
            alignLeft: true
            maxHeight: Math.round(root.height * 0.6)
        }

        MouseArea {
            id: modalScrim
            anchors.fill: parent
            z: 200
            enabled: launcher.alertModel.visible
            visible: dim.opacity > 0
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: alertDialog.close()
            onWheel: function (wheel) {
                wheel.accepted = true;
            }

            Rectangle {
                id: dim
                x: root.shadowPadding
                y: root.shadowPadding
                width: parent.width - 2 * root.shadowPadding
                height: parent.height - 2 * root.shadowPadding
                radius: root.shadowPadding > 0 ? Config.borderRounding : 0
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.5)
                opacity: launcher.alertModel.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        AlertDialog {
            id: alertDialog
        }
    }

    Connections {
        target: launcher.alertModel
        function onVisibleChanged() {
            if (launcher.alertModel.visible) {
                alertDialog.open();
            } else {
                if (alertDialog.visible)
                    alertDialog.close();
                searchBar.focusInput();
            }
        }
    }

    Connections {
        target: launcher
        function onCommandViewPushed(componentUrl, properties) {
            commandStack.push(componentUrl, properties, StackView.PushTransition);
        }
        function onCommandViewReplaced(componentUrl, properties) {
            commandStack.replace(commandStack.currentItem, componentUrl, properties, StackView.ReplaceTransition);
        }
        function onCommandViewPopped() {
            if (commandStack.depth > 1)
                commandStack.pop(StackView.PopTransition);
        }
        function onOverlayChanged() {
            if (launcher.hasOverlay) {
                overlayLoader.setSource(launcher.overlayUrl, {
                    host: launcher.overlayHost
                });
            } else {
                overlayLoader.source = "";
                searchBar.focusInput();
            }
        }
    }

    Connections {
        target: Nav
        function onWindowVisiblityChanged(visible) {
            if (visible) {
                root.aboutToShow();
                if (root.autoPlaceOnShow)
                    launcher.positionOnCursorScreen();
                root.visible = true;
                root.raise();
                root.requestActivate();
                searchBar.focusInput();
                root.shown();
            } else {
                root.visible = false;
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: !launcher.alertModel.visible && !actionPanel.open && !footerPanel.open && !launcher.hasOverlay
        onActivated: launcher.handleEscape()
    }

    Shortcut {
        sequence: "Shift+Escape"
        enabled: !launcher.alertModel.visible
        onActivated: launcher.popToRoot()
    }

    Shortcut {
        sequence: Keybinds.toggleActionPanelSequence
        enabled: !launcher.alertModel.visible
        onActivated: {
            if (launcher.compacted)
                launcher.expand();
            actionPanel.toggle();
        }
    }

    onWidthChanged: {
        if (launcher.canPositionWindow && root.autoPlaceOnShow)
            root.x = Screen.virtualX + (Screen.width - root.width) / 2;
    }
    onHeightChanged: {
        if (launcher.canPositionWindow && root.autoPlaceOnShow)
            root.y = Screen.virtualY + (Screen.height - root.height) / 3;
    }

    Component.onCompleted: {
        if (launcher.canPositionWindow && root.autoPlaceOnShow) {
            root.x = Screen.virtualX + (Screen.width - root.width) / 2;
            root.y = Screen.virtualY + (Screen.height - root.height) / 3;
            launcher.positionOnCursorScreen();
        }
    }
}
