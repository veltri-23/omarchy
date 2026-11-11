import QtQuick
Item {
    id: pet
    property bool animate: false
    property url spriteSource: "qrc:/tuxterm-idle.png"
    implicitWidth: 72
    implicitHeight: 78
    AnimatedSprite {
        objectName: "petSprite"
        anchors.fill: parent
        source: pet.spriteSource
        frameWidth: 96
        frameHeight: 104
        frameCount: 6
        frameRate: 6
        interpolate: false
        running: pet.animate && pet.visible
    }
}
