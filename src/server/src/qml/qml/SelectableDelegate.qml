import QtQuick
import QtQuick.Effects

/// Reusable delegate base for list items.  Provides a Source-blended
/// rounded-rect background that highlights on selection/hover, a MouseArea
/// for click handling, and a content slot for view-specific layouts.
Item {
    id: root

    property bool selected: false
    property bool draggable: false
    readonly property bool hovered: mouseArea.containsMouse && HoverActivation.active

    default property alias contentData: contentItem.data

    signal clicked
    signal activated
    signal dragRequested(var source)

    DraggableMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        draggable: root.draggable
        onItemClicked: {
            root.clicked();
            if (Config.activateOnSingleClick)
                root.activated();
        }
        onItemActivated: root.activated()
        onDragRequested: root.dragRequested(root)
    }

    Rectangle {
        id: rect

        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        radius: 5
        opacity: 0

        gradient: StapleGradient {}

        border {
            color: "#61000000"
            pixelAligned: true
            width: 1
        }
    }

    MultiEffect {
        id: effect

        source: rect
        opacity: 0
        anchors.fill: rect
        blurEnabled: true
        shadowEnabled: true
    }

    transitions: Transition {
        NumberAnimation { target: rect; property: "opacity"; duration: 200 }
        NumberAnimation { target: effect; property: "opacity"; duration: 200 }
    }

    states: [
        State {
            name: "isVisible"; when: root.selected || root.hovered
            PropertyChanges { rect.opacity: 1 }
            PropertyChanges { effect.opacity: 0.5 }
        },
        State {
            name: "invisible"; when: !(root.selected || root.hovered)
            PropertyChanges { rect.opacity: 0 }
            PropertyChanges { effect.opacity: 0 }
        }
    ]

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
