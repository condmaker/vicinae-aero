import QtQuick

Gradient {
    readonly property color shellColor: "#ff222222"
    readonly property color brightColor: Qt.hsla(shellColor.hslHue, shellColor.hslSaturation, shellColor.hslLightness + 0.2, 0.75)
    readonly property color lightColor: Qt.hsla(shellColor.hslHue, shellColor.hslSaturation, shellColor.hslLightness + 0.05, 0.85)
    readonly property color darkColor: Qt.hsla(shellColor.hslHue, shellColor.hslSaturation, shellColor.hslLightness - 0.35, 0.75)
    readonly property color darkerColor: Qt.hsla(shellColor.hslHue, shellColor.hslSaturation, shellColor.hslLightness - 0.4, 0.65)

    GradientStop {
        position: 0; color: darkColor
    }
    GradientStop {
        position: 0.2; color: shellColor
    }
    GradientStop {
        position: 0.6; color: lightColor
    }
}
