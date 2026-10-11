# end-4 Shell Mode

> **Status: untested on real hardware.** Verified in a sandbox HOME only:
> the switch, deploy, matugen palette (rendered with matugen 4.2.0), Orbit's
> adapters on that palette, `bootstrap/verify`, and the contract tests.
> end-4's shell itself has not been started here.

Orbit can run [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)'s
**illogical-impulse** Quickshell shell in place of Noctalia. You get its bar,
sidebars, overview, search, notifications, and Material You look. Orbit keeps
everything on the compositor side: workspace policy, Alt+Tab, Hyprglass
windows, focus ripples, Dynamic Cursors, the animated wallpaper, and the
lock/login choreography.

## Install

From the Orbit checkout, inside a Hyprland session:

```sh
./bin/install-end4-shell
```

Then log out and back in. The installer:

1. Clones end-4 at the pinned commit `2f2a376` into `~/.cache/orbit-end4/`.
2. Runs end-4's `./setup install --skip-allfiles --skip-sysupdate --skip-plasmaintg`
   for dependencies, its Python venv, and system setup. end-4 installs with
   `--noconfirm`, which aborts on package conflicts, so the installer first
   removes Arch's `quickshell` and `adw-gtk-theme` (`pacman -Rdd`). end-4's
   `illogical-impulse-quickshell-git` and `adw-gtk-theme-git` provide both.
   Orbit's global menu works with end-4's Quickshell.
3. Copies `quickshell/ii` and the matugen templates. Anything replaced goes to
   `~/orbit-backup-end4-<timestamp>/`. Orbit's links are never deleted.
4. Clears end-4's image wallpaper, so Orbit's animated wallpaper shows.
5. Runs `orbit-desktop-shell set ii` and `bootstrap/deploy`.

Rerun with `--skip-deps` to refresh files only.

**Switch back:** `orbit-desktop-shell set noctalia`, then log out and in.
Noctalia stays installed.

## Keys

Orbit's bindings are unchanged. end-4's shell keys that collided were moved:

| Action | Key | end-4 default |
|---|---|---|
| Search / launcher | tap Super, or Super+Space | tap Super |
| Overview | Super+Tab | same |
| Left sidebar (AI, translator) | Super+B or Super+O | Super+A (Orbit: ChatGPT) |
| Right sidebar (quick settings, notifications) | Super+N | same |
| Clipboard history | Super+Shift+V | Super+V (Orbit: float toggle) |
| Emoji | Super+. | same |
| Media controls | Super+Shift+M | Super+M (Orbit: shutdown) |
| Region screenshot | Super+Shift+S | same |
| Region record | Super+Alt+R | Super+Shift+R (Orbit: GPU recorder) |
| Cheatsheet | Super+/ | same |
| Bar toggle | Super+J | same |
| Session menu | Ctrl+Alt+Delete | same |
| Pick accent colour from screen | Ctrl+Super+T | wallpaper picker |
| Light/dark | Ctrl+Super+Shift+D | same |
| Restart shell | Ctrl+Super+R | same |

Lock stays **Super+L**, and shutdown/logout stays **Super+M**: Orbit's
animated flows, with Hyprlock.

## Colours

Orbit's animated wallpaper has no image to extract colours from, so the
palette comes from an **accent colour**. Ctrl+Super+T picks one from the
screen (end-4 stores it as `appearance.palette.accentColor`). end-4's `switchwall.sh` runs
matugen with Orbit's `config/matugen/config.toml`, which renders:

- end-4's own outputs (shell colours, fuzzel, KDE). GTK goes to
  `~/.config/gtk-{3,4}.0/noctalia.css`, which Orbit's `gtk.css` imports;
  end-4's default would overwrite `gtk.css`, an Orbit symlink.
- `~/.config/hypr/noctalia.lua` and `~/.config/wezterm/colors/Noctalia.toml`
  in Noctalia's format. Then `orbit-update-all-colors` and the wallpaper's
  `palette` command run, so borders, GTK, Kitty, WezTerm, Hyprlock and the
  wallpaper all follow.

`orbit-ii-palette [#RRGGBB]` regenerates the palette by hand. Without an
argument it reuses end-4's accent, else Orbit's current primary colour.

Terminal hues come from matugen custom colours (`[config.custom_colors]`)
blended toward the accent. Edit them in `config/matugen/config.toml`.

## Files

| File | Role |
|---|---|
| `bin/orbit-desktop-shell` | `get` / `is NAME` / `set noctalia\|ii`; state in `~/.config/orbit/shell` |
| `bin/install-end4-shell` | Installer above |
| `bin/orbit-ii-palette` | Manual palette regeneration |
| `config/hypr/shells/ii.lua` | end-4 env, keybinds, layer rules (adapted from end-4, GPL-3.0) |
| `config/hypr/hyprland.lua` | Starts `qs -c ii` instead of Noctalia and the global menu when selected |
| `config/matugen/` | matugen config and Orbit palette templates |
| `bin/orbit-noctalia-session-chrome` | Hides/shows end-4's bar over `qs -c ii ipc call bar` during lock/login |
| `systemd/user/hyprpolkitagent.service` | Skipped in ii mode; end-4 has its own agent |

end-4's shell configuration (bar layout, widgets, sidebars) lives in
`~/.config/illogical-impulse/config.json`. Edit it through its settings app
(`qs -p ~/.config/quickshell/ii/settings.qml`) or by hand.

## Known Risks

- end-4 targets its own pinned Quickshell build; Orbit's global-menu QML is
  only used in Noctalia mode, so a Quickshell API difference would not affect
  ii mode.
- end-4's wallpaper selector (still reachable from its UI) sets an image and
  covers Orbit's animated wallpaper. Clear it with
  `jq '.background.wallpaperPath=""' ~/.config/illogical-impulse/config.json`.
- end-4's setup step also sets the GNOME font and dark preference and installs
  its KDE/Kvantum pieces; Orbit's hyprqt6engine still themes Qt.
- `tests/orbit/run-soak` still assumes Noctalia.
- Updating end-4: change the pinned commit in `bin/install-end4-shell`,
  rerun it, and check `config/hypr/shells/ii.lua` against end-4's
  `dots/.config/hypr/hyprland/keybinds.lua` and `rules.lua`.
