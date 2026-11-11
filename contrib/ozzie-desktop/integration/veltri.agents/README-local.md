# Stable agent launch buttons

This clone of the installed Omarchy 4.5.0 Agents panel adds the per-provider terminal buttons already present upstream. It adds no services or polling. Agents without their own CLI keep their existing display.

`launch-agent` invokes the installed Omarchy launcher with a process-local default lookup, preserving its terminal styling, command flags and selected account. It does not write the saved default. The provider-to-CLI mapping follows upstream.

To undo, enable `omarchy.agents` with `omarchy plugin enable omarchy.agents`. When Stable includes these controls, return to the built-in widget to receive its future updates.

Each account row has its own launch button. It pins the account for that window without changing the active account or autoswitch mode; Main uses the implicit default config location. The provider-level button remains for providers with one account.

Muse has its own provider-style card below the subscription cards, with its
mark, Desktop label, description, and an Open action. It uses the same
ProviderSection component as Claude and Codex. The action launches the full
Muse chat app or focuses its existing window and is keyboard-accessible.
No Muse Code CLI, token collector, or invented usage meters are involved.

Ozzie is between the subscription cards (Codex) and Muse. Its TuxTerm idle sprite runs at 6 fps only while the panel is open and animations are enabled. Clicking the penguin, name, or Open button launches or focuses ozzie-desktop. The row is included in keyboard navigation. No new polling or background service is added.
