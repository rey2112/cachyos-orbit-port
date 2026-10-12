# Fedora Asahi Remix (Apple Silicon)

The `asahi` branch runs Orbit on Fedora Asahi Remix, written for a 14"
MacBook Pro with M2 Pro. It is the CachyOS port's look (Orbit-Mono palette,
glass bar and dock, WASD binds, no window ripples) plus a laptop layer.
**Untested on hardware**: nothing here has run on a Mac yet.

## Install

1. Install Fedora Asahi Remix with its official installer from macOS.
2. Enable the COPR for Hyprland and QuickShell (Noctalia 5.2.1 is in
   Fedora 44's own `updates` repo). `lionheartp/Hyprland` ships Hyprland
   0.56.2 and QuickShell for `aarch64`:

   ```sh
   sudo dnf copr enable -y lionheartp/Hyprland
   ```
3. Inside a Hyprland session:

   ```sh
   git clone -b asahi https://github.com/rey2112/cachyos-orbit-port ~/src/orbit-dotfiles
   cd ~/src/orbit-dotfiles
   ./bootstrap/asahi-first-run
   ```

   It installs packages with `bootstrap/install-packages-fedora` (and lists
   any that no enabled repository provides), backs up your config, deploys,
   builds Hyprglass, builds the Wallpaper Engine from
   source and writes a summary to `~/orbit-first-run-summary.txt`.
4. Log out and start a new Hyprland session.

## What differs from x86-64

| Area | On Apple Silicon |
|---|---|
| Wallpaper Engine | The tracked `bin/orbit-wallpaper-engine` is x86-64. `bin/install-wallpaper-engine-patched` builds v0.2.0 from source and points the service at it |
| ScrollOverview, HyprWindowShade, Dynamic Cursors | Not built. They hook compositor functions, which Hyprland supports only on x86-64: no workspace overview (Alt+Tab overview, swipe-up overview), no ripples (already off), static cursor |
| Hyprglass | Built from source with `config/hypr/patches/hyprglass-layer-glass-without-hooks.patch` (applied by `bin/install-hyprglass` off x86-64). Upstream draws bar/dock/panel glass from a `renderLayer` function hook, which Hyprland refuses on aarch64; the patch inserts the same glass steps into the frame's render pass at `RENDER_LAST_MOMENT` instead. Window glass needs no patch |
| NVIDIA settings | Skipped automatically (no `nvidia` module) |
| Games, Sunshine, GPU recorder | Leave the optional integrations off; x86 games need FEX/muvm and there is no hardware encoder |

## Laptop layer

`config/hypr/laptop.lua` loads only when `/sys/class/power_supply` reports a
battery, so a desktop on the same checkout is unaffected.

- Touchpad: natural scrolling, tap to click, two-finger right click,
  palm rejection while typing.
- Three-finger swipe left/right changes workspace (workspaces slide sideways on
  the laptop to match); three fingers up opens the app launcher.
- Brightness, keyboard backlight, volume, mic and media keys (`brightnessctl`,
  `wpctl`, `playerctl`).
- Battery (with percentage) and brightness in the bar's system island.
- Lid close and idle suspend lock first (`before_sleep_cmd` in
  `hypridle.conf`); logind's default lid action suspends.

## Display

`bootstrap/asahi-first-run` writes `~/.config/hypr/monitors.lua` only when
none exists: `eDP-1` at its preferred mode with scale 1.75 (1728x1080 of
workspace on the 3024x1890 panel with the notch hidden), and any other output
at its preferred mode. Use the HDMI port for an external screen. Change the
layout with `nwg-displays`.

Keep the notch hidden (Asahi's default). If you show it, the centred clock
sits under the notch; move it in `config/noctalia/orbit-bar.toml`.

## Keyboard

Super is ⌘ Command, Alt is ⌥ Option. The binds are the same as on the desktop
(Super+W close, Super+Alt+WASD focus, Super+Shift+WASD move,
Super+Ctrl+WASD resize). Screenshots: Super+Shift+X (the Mac has no Print key).

## Lock and login screens

The lock screen is neutral (fixed graphite, white and grey, set in Inter)
rather than following the Orbit-Mono palette. The login screen stays GDM.

- **Lock screen** (`config/hypr/hyprlock.conf`): date and a large time at the
  top, your name above a frosted password pill near the bottom, battery
  percentage bottom-right (`config/hypr/scripts/lock-battery`).
