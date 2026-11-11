import QtQuick
import QtTest
import "../src"
Item {
    width: 200; height: 200
    Pet {
        id: pet
        spriteSource: Qt.resolvedUrl("../assets/tuxterm-idle.png")
        animate: false
    }
    TestCase {
        name: "PetVisibility"
        when: windowShown
        function test_motionStopsWhenHiddenOrPaused() {
            const sprite = findChild(pet, "petSprite")
            verify(sprite !== null)
            tryCompare(sprite, "running", false)
            const still = sprite.currentFrame
            wait(200)
            compare(sprite.currentFrame, still)
            pet.animate = true
            tryCompare(sprite, "running", true)
            tryVerify(function() { return sprite.currentFrame !== still }, 2000)
            pet.visible = false
            tryCompare(sprite, "running", false)
            const hidden = sprite.currentFrame
            wait(400)
            compare(sprite.currentFrame, hidden)
            pet.visible = true
            pet.animate = false
            tryCompare(sprite, "running", false)
        }
    }
}
