import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtWebEngine

ApplicationWindow {
    id: root
    width: 1100
    height: 820
    visible: true
    title: "Ozzie"
    color: "#171717"
    Material.theme: Material.Dark
    Material.accent: backend.accent
    property bool motionEnabled: true
    property string errorMessage: backend.homeUrl.toString() === "" ? qsTr("Ozzie’s conversation link is not configured.") : ""
    property bool renderPet: visible && visibility !== Window.Minimized && active

    WebEngineProfile {
        id: ozzieProfile
        storageName: smokeTest ? "OzzieTest" : "Ozzie"
        offTheRecord: smokeTest
        httpCacheMaximumSize: 67108864
    }
    header: ToolBar {
        height: 88
        Material.background: "#242424"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            Pet { Layout.preferredWidth: 60; Layout.preferredHeight: 65; animate: root.renderPet && root.motionEnabled }
            Label { text: "Ozzie"; textFormat: Text.PlainText; font.pixelSize: 23; font.bold: true }
            Item { Layout.fillWidth: true }
            Button { text: qsTr("Ozzie"); onClicked: web.url = backend.homeUrl }
            Button { text: qsTr("Plugins"); onClicked: web.url = "https://chatgpt.com/plugins" }
            ToolButton {
                text: root.motionEnabled ? qsTr("Pause pet") : qsTr("Animate pet")
                onClicked: root.motionEnabled = !root.motionEnabled
            }
            ToolButton { text: qsTr("Reload"); onClicked: web.reload() }
            ToolButton {
                text: "×"
                font.pixelSize: 26
                Accessible.name: qsTr("Close Ozzie")
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Close Ozzie")
                onClicked: Qt.quit()
            }
        }
    }
    Item {
        anchors.fill: parent
        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true
        WebEngineView {
            id: web
            anchors.fill: parent
            profile: ozzieProfile
            backgroundColor: root.color
            url: smokeTest ? "about:blank" : backend.homeUrl
            userScripts.collection: [{
                name: "Ozzie focused interface",
                injectionPoint: WebEngineScript.DocumentReady,
                worldId: WebEngineScript.MainWorld,
                runsOnSubFrames: false,
                sourceCode: backend.focusScript
            }]
            onNavigationRequested: function(request) {
                if (!request.isMainFrame || smokeTest || backend.internalUrl(request.url)) return
                request.reject()
                if (backend.externalUrl(request.url)) Qt.openUrlExternally(request.url)
            }
            onPermissionRequested: function(request) {
                permissionDialog.request = request
                permissionDialog.open()
            }
            onNewWindowRequested: function(request) {
                // Authentication can use a popup and requires this app's own session.
                if (backend.internalUrl(request.requestedUrl) || request.requestedUrl.toString() === "") {
                    const popup = popupComponent.createObject(root)
                    request.openIn(popup.view)
                    popup.show()
                } else if (backend.externalUrl(request.requestedUrl)) Qt.openUrlExternally(request.requestedUrl)
            }
            onLoadingChanged: function(info) {
                if (info.status === WebEngineView.LoadFailedStatus) root.errorMessage = info.errorString
                else if (info.status === WebEngineView.LoadSucceededStatus) root.errorMessage = ""
            }
            // Respect Chromium's recommendation so active calls/audio are not frozen.
            lifecycleState: !visible && recommendedState === WebEngineView.LifecycleState.Frozen ? WebEngineView.LifecycleState.Frozen : WebEngineView.LifecycleState.Active
            visible: root.visibility !== Window.Minimized
        }
        Column {
            anchors.centerIn: parent
            visible: smokeTest
            spacing: 20
            Pet { anchors.horizontalCenter: parent.horizontalCenter; width: 144; height: 156; animate: true }
            Label { text: qsTr("Ozzie and your plugins, in one window."); textFormat: Text.PlainText }
        }
    }
    footer: Label {
        visible: root.errorMessage !== ""
        text: qsTr("Could not load the page: %1").arg(root.errorMessage)
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        padding: 12
    }
    Dialog {
        id: permissionDialog
        property var request
        anchors.centerIn: parent
        modal: true
        title: qsTr("Website permission")
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: Label {
            width: 430
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            text: {
                if (!permissionDialog.request) return ""
                const names = [qsTr("an unsupported feature"), qsTr("your microphone"),
                    qsTr("your camera"), qsTr("your microphone and camera"), qsTr("your screen"),
                    qsTr("your screen and audio"), qsTr("pointer lock"), qsTr("notifications"),
                    qsTr("your location"), qsTr("your clipboard"), qsTr("installed fonts")]
                return qsTr("Allow %1 to access %2?").arg(permissionDialog.request.origin)
                    .arg(names[permissionDialog.request.permissionType] || qsTr("this feature"))
            }
        }
        onAccepted: request.grant()
        onRejected: request.deny()
    }
    Component {
        id: popupComponent
        ApplicationWindow {
            id: popup
            width: 900; height: 760
            title: qsTr("Ozzie — sign in")
            property alias view: popupWeb
            WebEngineView {
                id: popupWeb
                anchors.fill: parent
                profile: ozzieProfile
                onWindowCloseRequested: popup.close()
                onPermissionRequested: function(request) { request.deny() }
                onNavigationRequested: function(request) {
                    if (!request.isMainFrame || backend.internalUrl(request.url)) return
                    request.reject()
                    if (backend.externalUrl(request.url)) Qt.openUrlExternally(request.url)
                }
            }
            onClosing: destroy()
        }
    }
    Shortcut { sequence: "Ctrl+Q"; context: Qt.ApplicationShortcut; onActivated: Qt.quit() }
    Shortcut { sequence: "Ctrl+R"; context: Qt.ApplicationShortcut; onActivated: web.reload() }
    Shortcut { sequence: "Alt+Left"; context: Qt.ApplicationShortcut; onActivated: web.goBack() }
    Shortcut { sequence: "Ctrl+1"; context: Qt.ApplicationShortcut; onActivated: web.url = backend.homeUrl }
    Shortcut { sequence: "Ctrl+2"; context: Qt.ApplicationShortcut; onActivated: web.url = "https://chatgpt.com/plugins" }
}
