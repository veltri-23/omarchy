# Ozzie

A small Qt Quick / Qt WebEngine window for one existing ChatGPT Dot and its plugins. The local TuxTerm idle animation appears in the app header and Omarchy Agents drawer. This is an unofficial website wrapper, not a replacement Dot service or API client.

## Build and install

Requires Qt 6 base, declarative, Quick Controls, WebEngine, Wayland, qmake6, make, and a C++17 compiler. Run `bin/build`, `bin/test`, then `bin/install-local`. The user-local app appears as **Ozzie**. Closing it exits the process; no background service or autostart is installed.

Set the Dot conversation URL in `~/.config/ECHO/ozzie-desktop.conf`:

```ini
[General]
homeUrl=https://chatgpt.com/dots/YOUR-DOT-ID
```

Sign in inside the new window. Its profile is separate from Chrome and the full ChatGPT app. Cookies, browser storage, and authentication material must never be copied into this repository or backups.

## Interface

- Ozzie opens the configured Dot; Plugins opens the website's plugin directory.
- The native top-right × button closes Ozzie. Omarchy's normal window decoration remains available.
- TuxTerm animates locally at 6 fps; Pause pet stops it. The header pauses when the app loses focus, is hidden, or is minimized.
- The six-frame 576×104 idle strip occupies approximately 234 KiB when decoded to RGBA, excluding Qt/GPU overhead. The webpage remains the dominant memory cost. The full sprite sheet is not loaded at runtime.
- Minimizing allows the page to freeze when Chromium recommends it; active audio/calls keep their normal lifecycle. There is no polling timer.
- The focus script hides known ChatGPT sidebar selectors and detects the current narrow ChatGPT-branded navigation rail on Dot/plugin pages. Its mutation observer disconnects once the rail is found. It blocks unrelated same-site navigation links in that focused view. This is UI customization, not a security boundary. Website updates may require selector adjustments.
- Authentication and plugin settings retain their normal pages. External links open in the default browser.
- This wrapper does not replace ChatGPT's local computer connection.

| Shortcut | Action |
| --- | --- |
| Ctrl+1 | Ozzie |
| Ctrl+2 | Plugins |
| Ctrl+R | Reload |
| Alt+Left | Back |
| Ctrl+Q | Quit |

## Agents integration

`integration/veltri.agents` is the user's existing Omarchy Agents clone with an Ozzie card inserted after the subscription cards (currently Claude and Codex), immediately above Muse. The penguin and name are clickable, and arrow-key/Enter navigation includes Ozzie. The small sprite runs only when the drawer is open and Omarchy animations are enabled. It displays idle motion, not invented live task status.

Apply the reviewed `Panel.qml`, `i18n/en.json`, `README-local.md`, and `assets/ozzie-idle.png` to the matching user plugin. Back up existing files first. Do not overwrite packaged Omarchy files. Validate with `omarchy plugin validate <plugin-folder>` and reload with `omarchy-shell shell rescanPlugins`.

## Verification

`bin/test` checks that pet frames stop when hidden or paused, and checks route handling, including lookalike hosts, unrelated chats, unsafe URL schemes, and invalid configuration. `--smoke-test` renders the real QML with a blank offline page and exits after saving a screenshot to `/tmp/ozzie-smoke.png` (override with `OZZIE_TEST_SCREENSHOT`). It uses an off-the-record profile. Live sign-in, plugin authorization, and website layout require separate checks.

TuxTerm artwork is the user's existing selected ChatGPT pet, downloaded through the Pets connector. No pet record was changed. The idle strip and icon are crops of that existing artwork; they were not redrawn.
