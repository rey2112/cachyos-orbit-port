# CachyOS Port

> **Status: untested.** This port was prepared without access to a CachyOS
> machine. Nothing below has been run on CachyOS, Hyprland, systemd, or with
> the NVIDIA driver. What *was* run is listed in [What Was Checked](#what-was-checked).
> Target: CachyOS (Arch-based), Ryzen 7 5800X, RTX 3070 Ti, proprietary
> NVIDIA driver.

## Install Steps

Run these as your desktop user, inside a Hyprland session (Noctalia must be
running for the template steps). Bootloader, initramfs, and Plymouth stay
manual and are not touched.

1. Install CachyOS with the Hyprland edition, or install `hyprland` and
   `noctalia` on an existing CachyOS install. Let `chwd` manage the NVIDIA
   driver.
2. At the display manager, pick the plain **Hyprland** session, not
   "Hyprland (uwsm-managed)". Orbit starts its own `hyprland-session.target`
   from `orbit-session-bootstrap`.
3. Clone this repository and check out the port branch:

   ```sh
   git clone https://github.com/rey2112/cachyos-orbit-port.git ~/src/orbit-dotfiles
   cd ~/src/orbit-dotfiles
   ```

4. Run the one-shot script and paste the summary table back for review:

   ```sh
   ./bootstrap/cachyos-first-run
   ```

   Hyprland reloads its config when `~/.config/hypr/hyprland.lua` changes,
   so the desktop switches to Orbit mid-run. That is expected.
5. Rename your Noctalia bar to `Top` if the `noctalia-bar-name` step failed
   (see [Top Bar](#top-bar)).
6. Run `nwg-displays` to replace the placeholder `~/.config/hypr/monitors.lua`.
7. Log out and start a new Hyprland session. If `input-group` added you to
   `input`, the new login also applies that membership.
8. In the new session: `./tests/orbit/run-all --live`.

`cachyos-first-run` runs, in order: platform check, `install-packages-arch`,
polkit agent path report, `input` group membership, a tarball backup of the
Orbit-touched `~/.config`/`~/.local` paths, `bootstrap/migrate --dry-run`,
a placeholder `monitors.lua`, moving blocked files into the backup,
`bootstrap/deploy`, a Noctalia output check, a bar-name check, the four
plugin installers, the Oblique cursor theme, `bin/dotfiles-install-wallpaper`,
`bootstrap/verify`, then `tests/orbit/run-all` (plus `--live` inside Hyprland).
A failing step never stops the run. Output goes to `~/orbit-first-run.log`;
the table also goes to `~/orbit-first-run-summary.txt`; backups go to
`~/orbit-backup-<timestamp>/` (`home-config.tar.gz` plus `conflicts/`).

Options: `--skip-packages` (rerun without pacman/paru), `--force` (skip the
CachyOS check). `bootstrap/install-packages-arch` also takes `--optional`
(Steam, GameMode, Obsidian, Zed, Zen, Sunshine, …) and `--dry-run`.

### Files CachyOS Already Puts In Your Home

The Hyprland edition seeds these from `/etc/skel` (from `cachyos-hypr-noctalia`
1.2.6). They block `bootstrap/deploy`, so the first-run script moves them to
`~/orbit-backup-<timestamp>/conflicts/`:

- `~/.config/hypr/hyprland.lua` (CachyOS's `~/.config/hypr/config/*.lua`
  modules are left in place, unused)
- `~/.config/kitty/kitty.conf`
- `~/.config/gtk-3.0/gtk.css`, `~/.config/gtk-4.0/gtk.css`
- `~/.config/qt6ct/qt6ct.conf`

`~/.config/noctalia/config.toml` (your bar and shell settings) is not touched.

## Package Mapping

Checked 2026-10-08. `archlinux.org`, `aur.archlinux.org`, and CachyOS
package sites were unreachable from the build environment. Instead:
official repos via the `archlinux/state` repo snapshot (commit `4bfbd3c`,
2026-10-08 02:27 UTC), AUR via the `archlinux/aur` GitHub mirror, CachyOS via
`CachyOS/CachyOS-PKGBUILDS`. `archlinux/state` lists *pkgbase*, so split
package names marked † were mapped from the pkgbase and their file lists
were not inspected.

| Fedora | Arch / CachyOS | Source | Version |
|---|---|---|---|
| hyprland | hyprland | extra | 0.56.2-4 |
| hypridle | hypridle | extra | 0.1.8-2 |
| hyprlock | hyprlock | extra | 0.9.6-3 |
| hyprpolkitagent | hyprpolkitagent | extra | 0.2.0-1 |
| noctalia (5.0.0~beta.9) | noctalia | extra | **5.2.1-1** (release, not beta) |
| quickshell | quickshell | extra | 0.3.1-1 |
| nwg-displays | nwg-displays | extra | 0.4.4-1 |
| xdg-desktop-portal(-hyprland) | xdg-desktop-portal, xdg-desktop-portal-hyprland | extra | 1.22.1-2, 1.4.1-2 |
| python3 | python | core | 3.14.7-1 |
| python3-pyudev | python-pyudev | extra | 0.24.4-1 |
| *(not listed upstream)* | python-evdev | extra | 2.0.0-1 |
| *(not listed upstream)* | python-dbus † | extra (dbus-python) | 1.5.0-1 |
| python3-gobject | python-gobject † | extra (pygobject) | 3.58.0-1 |
| jq, socat | jq, socat | extra | 1.8.2-1, 1.8.1.3-1 |
| util-linux(-core) | util-linux | core | 2.42.4-1 |
| shadow-utils | shadow | core | 4.20.0.arch1-1 |
| procps-ng | procps-ng | core | 4.0.7-1 |
| grim, slurp | grim, slurp | extra | 1.5.0-2 |
| wl-clipboard | wl-clipboard | extra | 2.3.0-1 |
| zenity | zenity | extra | 4.2.2-1 |
| libcanberra-gtk3 | libcanberra | extra | 0.30+r2-6 |
| alsa-utils | alsa-utils | extra | 1.2.16-1 |
| git, gcc-c++, make, pkgconf, patch | git, gcc, make, pkgconf, patch | core/extra | 2.56.0, 16.2.1, 4.4.1, 3.0.7, 2.8 |
| pixman/libdrm/pango/libinput/xkbcommon/wayland -devel | pixman, libdrm, pango, libinput, libxkbcommon, wayland (headers included) | extra | — |
| systemd-devel (libudev) | systemd-libs † | core (systemd) | 262-1 |
| lua-devel ("5.4" upstream) | **lua (5.5)**, not `lua54` | extra | 5.5.1-1 |
| *(implicit)* | cairo, libpng, mesa, libglvnd, cmake, meson, cpio | core/extra | — |
| *(implicit)* | qt6ct, qt6-wayland, ttf-jetbrains-mono, adwaita-cursors †, gsettings-desktop-schemas, gvfs, at-spi2-core | extra | — |
| *(implicit)* | hyprqt6engine | **AUR** | 0.1.0-4 |
| Kora icons | kora-icon-theme | **AUR** | 2.0.6-1 |
| nautilus-python | python-nautilus † | extra (nautilus-python) | 4.2.0-1 |
| *(NVIDIA VA-API)* | libva-nvidia-driver, egl-wayland | extra | 0.0.18-1 |

Not packaged: the Oblique cursor theme (installed by the first-run script
from `kayxean/oblique-cursor` at `ecddc55`), the Orbit Wallpaper Engine
(`bin/dotfiles-install-wallpaper`), and the four plugins (source builds).

## Hyprland Version

| | Version | Commit |
|---|---|---|
| Fedora reference | 0.56.2-1.fc44 | `efb50993780079460b0cbed1363e2166a2de1d9f` |
| Arch `extra` (2026-10-08) | 0.56.2-4 | upstream tag `v0.56.2` = `efb50993…` (verified with `git ls-remote`) |

Same upstream release, and no `v0.57` tag exists yet, so there is no Lua or
plugin API change between them. The Arch `-4` pkgrel means rebuilds against
newer dependencies (hyprutils 0.14.2, aquamarine 0.15.1). Arch packaging
patches could not be inspected (gitlab.archlinux.org was blocked). Plugins
are rebuilt locally against the installed headers either way.

Hyprland 0.56.2 requires **Lua 5.5** (`CMakeLists.txt` line 291). Do not
install `lua54` for the plugin builds.

## Plugin Pins

Unchanged from upstream Orbit, because Arch ships the exact Hyprland commit
they were validated against. "Verified" means the pin is confirmed to exist
upstream and to target Hyprland 0.56.2. It does **not** mean it was built
or loaded on CachyOS.

| Plugin | Pin | Basis | Status |
|---|---|---|---|
| Hyprglass | `5bc835d` (v0.7.0) | Orbit-validated on `efb5099`. Upstream's own hyprpm pin for `efb5099` is `99f30ca` (v0.9.1). | Verified exists; v0.9.1 is upstream's newer choice but changes the config API surface, so not adopted |
| ScrollOverview | `f9248ab` | Orbit-validated on `efb5099`. Upstream hyprpm.toml has no 0.56 pin. | Verified exists, on `main`; 0.56 match is Orbit's claim |
| HyprWindowShade | `40b756b` + Orbit patch | Orbit-validated. Upstream pin for `efb5099` is `a4c6b8a`; Orbit's patch targets `40b756b`. | Verified exists; patch `git apply --check` clean |
| Dynamic Cursors | `5a22428` (`origin/v0.56.2`) | Exactly upstream's hyprpm.toml pin for `efb5099` | Verified |
| Oblique cursor | `ecddc55` | Theme assets, not ABI-coupled | Verified exists |

Build changes for Arch: ScrollOverview builds with `LUA_PKG` set to the Lua
5.5 pkg-config module. HyprWindowShade falls back to `pkg-config hyprland`
headers when there is no hyprpm `headersRoot`. Dynamic Cursors now has
`bin/install-dynamic-cursors`.

## NVIDIA

CachyOS's `/etc/profile.d/Hyprland.sh` exports `GBM_BACKEND=nvidia-drm` and
`EGL_PLATFORM=wayland` for login shells only. Its Hyprland config leaves
`__GLX_VENDOR_LIBRARY_NAME` and `LIBVA_DRIVER_NAME` commented out.
`config/hypr/hyprland.lua` sets those two when `/sys/module/nvidia` is
loaded, and sets `GBM_BACKEND` only if it is unset. **Untested.**

## end-4 Shell Mode

To use end-4's illogical-impulse shell instead of Noctalia, while keeping
Orbit's compositor side, wallpaper and lock animation, see
[`end4-shell.md`](end4-shell.md).

## Top Bar

The bar is Noctalia's, not Orbit's. Keep these separate:

- **Your bar (Noctalia):** `~/.config/noctalia/config.toml`. Its `[bar.*]`
  tables define position, widgets, and layout. It is user-owned and not in
  this repo; on CachyOS it starts from `/etc/skel` as `[bar.default]`.
  Edit it here or in Noctalia's settings UI.
- **Orbit bar look:** `config/noctalia/orbit-bar.toml`, the thin dark
  full-width `Top` strip from the author's showcase (launcher, centred clock,
  status icons; JetBrains Mono); the dock is the floating island. It sorts
  after `config.toml`, so its values win; edit or delete lines freely. Changes
  saved from Noctalia's settings window go to
  `~/.local/state/noctalia/settings.toml` and win over both.
- **Orbit glue that touches the bar:**
  - `config/noctalia/orbit-shell.toml`: turns off Noctalia's polkit agent
    (Orbit runs `hyprpolkitagent`).
  - `config/noctalia/orbit-wallpaper.toml`: turns off Noctalia's wallpaper
    so Orbit's animated one shows.
  - `config/noctalia/90-orbit-glass.toml`: panel/dock/notification
    transparency.
  - `config/noctalia/hooks.toml`: palette-change hook.
  - `config/noctalia/orbit-templates.toml`: which colour templates
    Noctalia renders. It sorts after `config.toml` so its list wins; keep the
    `hyprland` and `wezterm` entries if you edit it.
  - `config/quickshell/global-menu/*.qml`: global menu that anchors to
    the layer named `noctalia-bar-Top`.
  - `bin/orbit-noctalia-session-chrome`: `noctalia msg bar-hide/bar-show Top`
    around login/logout.
  - `config/hypr/hyprland.lua`: `hl.layer_rule` entries matching
    `noctalia-bar-.+`.

Orbit expects the bar to be **named `Top`** (`[bar.Top]`). Rename
`[bar.default]` (and its sub-tables) to `[bar.Top]`, or update the two Orbit
references above if you choose another name.

## Known Risks

- **Everything is untested on CachyOS.** The first run will likely surface
  issues; paste the summary table back.
- **Noctalia 5.2.1 vs validated beta.9.** Statically confirmed: the
  `templates-apply`, `panel-toggle`, `bar-hide/show`, and `status` IPC
  commands exist, TOML drop-ins still merge, and the keys in
  `90-orbit-glass.toml`/`hooks.toml` exist. 5.2.1 dropped `local shadow` from
  the Hyprland template; `orbit-theme` now defaults it to black. Visual
  behaviour has not been checked.
- **uwsm.** CachyOS defaults to uwsm, which owns `graphical-session.target`.
  Orbit's `hyprland-session.target` binds to it. Running under uwsm is
  unvalidated; use the plain session.
- **hyprqt6engine** is an AUR Qt plugin. Rebuild it (`paru -S hyprqt6engine`)
  after `qt6-base` updates, or Qt apps lose the Orbit theme.
- **Plugins vs Arch rebuilds.** Any `hyprland` pkgrel bump can change the
  ABI. Rerun the four `bin/install-*` plugin installers after Hyprland
  updates.
- **hyprpolkitagent path.** The unit tries `/usr/libexec`,
  `/usr/lib/hyprpolkitagent/hyprpolkitagent`, then `/usr/lib/hyprpolkitagent`.
  The Arch path came from upstream CMake (`CMAKE_INSTALL_LIBEXECDIR`), not a
  package file list; the `polkit-agent-path` step prints the real one.
- **Rerunning deploy.** `orbit-theme` replaces the deployed
  `hypr/hyprqt6engine.conf` and `wezterm/wezterm.lua` symlinks with regular
  files, so a second plain `bootstrap/deploy` refuses them. The first-run
  script moves them aside first. This is an upstream issue.
- **Wallpaper Engine.** The tracked x86-64 ELF (`7a4c8cfb…`) is used unchanged;
  it links against system libwayland/EGL/libpng and has not been run on
  CachyOS or the NVIDIA EGL stack.
- **Plymouth.** `orbit.script` now loads `logo.png`, falling back to the
  Fedora logo; copy a CachyOS logo as `logo.png` when you install the theme
  manually.

## What Was Checked

Run in a Linux build container, not CachyOS:

- `bootstrap/verify --source` and the 25 contract tests pass (with
  `python-evdev` installed; without it 3 tests error, which is why it is now
  a listed dependency).
- `config/hypr/hyprland.lua` parses under Lua 5.5 and runs against a stub
  `hl` with and without NVIDIA/`QT_QPA_PLATFORMTHEME`.
- Shell scripts pass `bash -n`; new scripts pass `shellcheck -S warning`
  except for the upstream `CDPATH= cd` idiom.
- `cachyos-first-run` ran end to end as an unprivileged user in a sandbox
  HOME seeded with CachyOS's `/etc/skel` files, with stubbed `sudo`,
  `pacman`, `paru`, `systemctl`, and a `noctalia` that renders the real 5.2.1
  hyprland/wezterm templates. Conflict moves, deploy, verify, and contract
  tests passed. Plugin builds were not attempted (no Hyprland headers).
  This run found the deploy glob bug and the Noctalia `shadow` regression.
