-- end-4 "illogical-impulse" shell glue, loaded by hyprland.lua when
-- ~/.config/orbit/shell says "ii". Adapted from end-4/dots-hyprland
-- (GPL-3.0) dots/.config/hypr/hyprland/{variables,env,keybinds,rules}.lua.
-- Orbit keeps its own window, workspace, lock and session bindings; shell
-- bindings that collide with them are moved (noted inline).

local home = os.getenv("HOME")
local qsScripts = home .. "/.config/quickshell/ii/scripts"
local qsIpcCall = "qs -c ii ipc call"

-- Environment the shell and its scripts expect.
hl.env("qsConfig", "ii")
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home .. "/.local/state/quickshell/.venv")

-- Shell surfaces.
-- Tap Super: search. Hold Super: workspace numbers.
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"), { description = "Shell: Toggle search" })
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"))
for _, key in ipairs({ "SUPER_L", "SUPER_R" }) do
    hl.bind(key, hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
    hl.bind(key, hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true, release = true })
end
hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })
hl.bind("SUPER + SHIFT + V", hl.dsp.global("quickshell:overviewClipboardToggle")) -- end-4: Super+V (Orbit: float toggle)
hl.bind("SUPER + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))
hl.bind("SUPER + B", hl.dsp.global("quickshell:sidebarLeftToggle"), { description = "Shell: Toggle left sidebar" }) -- end-4 also Super+A (Orbit: ChatGPT)
hl.bind("SUPER + O", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind("SUPER + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind("SUPER + N", hl.dsp.global("quickshell:sidebarRightToggle"), { description = "Shell: Toggle right sidebar" })
hl.bind("SUPER + Slash", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind("SUPER + K", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + SHIFT + M", hl.dsp.global("quickshell:mediaControlsToggle")) -- end-4: Super+M (Orbit: shutdown)
hl.bind("SUPER + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })
hl.bind("SUPER + J", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind("CTRL + ALT + Delete", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Session menu" })
hl.bind("CTRL + SUPER + SHIFT + D", hl.dsp.global("quickshell:toggleLightDark"))
hl.bind("CTRL + SUPER + P", hl.dsp.global("quickshell:panelFamilyCycle"))
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("pkill -x qs; qs -c ii &"), { description = "Shell: Restart" })

-- Palette: Orbit's animated wallpaper replaces end-4's image wallpaper, so the
-- colour source is an accent picked from the screen instead of an image.
hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd(qsScripts .. "/colors/switchwall.sh --color"),
    { description = "Shell: Pick accent colour from screen" })

-- Utilities.
hl.bind("SUPER + SHIFT + A", hl.dsp.global("quickshell:regionSearch"))
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:regionOcr"))
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:screenTranslate"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("SUPER + ALT + R", hl.dsp.global("quickshell:regionRecord"), { locked = true }) -- end-4 also Super+Shift+R (Orbit: GPU recorder)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Layer rules: blur and motion for the shell's surfaces.
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true, blur_popups = true, ignore_alpha = 0.79 })
hl.layer_rule({ match = { namespace = "quickshell:background" }, blur = false })
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:verticalBar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:actionCenter" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:cheatsheet" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%" })
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, no_anim = true, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom", order = -1 })
hl.layer_rule({ match = { namespace = "quickshell:polkit" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:popup" }, xray = false, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:reloadPopup" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:regionSelector" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true, no_anim = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
