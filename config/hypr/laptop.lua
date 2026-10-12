-- Orbit laptop layer (Fedora Asahi Remix on a 14" MacBook Pro M2 Pro).
-- hyprland.lua loads this only when a battery is present, so a desktop
-- running the same checkout never sees it. UNTESTED on hardware.

-- Touchpad: macOS-like scrolling and clicking.
hl.config({
    input = {
        touchpad = {
            natural_scroll = true,        -- Content follows the fingers, as on macOS.
            tap_to_click = true,          -- Light tap clicks.
            clickfinger_behavior = true,  -- Two-finger click = right click, three = middle.
            disable_while_typing = true,  -- Ignore palm touches while typing.
        },
    },
})

-- macOS / GNOME style gestures:
--   three fingers left/right  previous / next workspace (follows the fingers)
--   three fingers up           workspace overview (ScrollOverview, as Alt+Tab)
--   three fingers down         close the overview
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
local function overview(command)
    return function()
        if hl.plugin.scrolloverview then
            hl.plugin.scrolloverview._dispatch("overview", command)
        end
    end
end
hl.gesture({ fingers = 3, direction = "up", action = overview("open all") })
hl.gesture({ fingers = 3, direction = "down", action = overview("close all") })

-- Workspaces slide sideways on the laptop so the animation matches the
-- horizontal swipe (the desktop keeps Orbit's vertical slide). Same spring
-- and speeds as hyprland.lua.
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.1, spring = "orbitTunedB", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.45, spring = "orbitTunedB", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.0, spring = "orbitTunedB", style = "slide" })

-- Function-row keys (hold fn on the Mac keyboard if the row sends F1-F12).
local laptopKeys = {
    XF86MonBrightnessUp = "brightnessctl -e4 -n2 set 5%+",
    XF86MonBrightnessDown = "brightnessctl -e4 -n2 set 5%-",
    XF86KbdBrightnessUp = "brightnessctl -d '*kbd_backlight' set 10%+",
    XF86KbdBrightnessDown = "brightnessctl -d '*kbd_backlight' set 10%-",
    XF86AudioRaiseVolume = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
    XF86AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
    XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
    XF86AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
}
for key, command in pairs(laptopKeys) do
    hl.bind(key, hl.dsp.exec_cmd(command), { locked = true, repeating = true })
end
for key, command in pairs({
    XF86AudioPlay = "playerctl play-pause",
    XF86AudioPause = "playerctl play-pause",
    XF86AudioNext = "playerctl next",
    XF86AudioPrev = "playerctl previous",
}) do
    hl.bind(key, hl.dsp.exec_cmd(command), { locked = true })
end
