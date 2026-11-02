-- Change the default Omarchy look'n'feel.

-- Make Qt5/Qt6 apps follow the Greybird GTK2 theme (Xubuntu look).
-- Overrides Omarchy's default `QT_QPA_PLATFORMTHEME=gtk3` from envs.lua,
-- which is loaded before this file. The gtk2 platform theme is provided by
-- qt5-styleplugins (Qt5) and qt6gtk2 (Qt6); both read ~/.gtkrc-2.0.
hl.env("QT_QPA_PLATFORMTHEME", "gtk2")

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
local smart_border_size = 1 -- border width when 2+ windows share the workspace

hl.config({
  general = {
    -- No gaps between windows.
    gaps_in = 0,
    gaps_out = 0,

    -- Thin border to highlight the active window (Tokyo Night accent).
    -- Actual size is managed by the smart-border logic below.
    border_size = smart_border_size,
    col = {
      active_border = "rgba(7aa2f7ee)",
      inactive_border = "rgba(565f8966)",
    },
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
  },
})

-- Low-contrast screen shader: pulls whites down and blacks up (like `xcalib -co 70`).
-- Tune CONTRAST / TINT in the shader file itself.
-- Set to "" (or comment this out + `hyprctl reload`) to disable.
hl.config({
  decoration = {
    screen_shader = "/home/kh/.config/hypr/shaders/low-contrast.frag",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Smart border: with gaps off, a border is the only active-window highlight,
-- but a lone window looks better borderless. Show the border only when the
-- active workspace has more than one window.
local function update_smart_border()
  local ws = hl.get_active_workspace()
  if ws == nil then
    return
  end

  local windows = hl.get_workspace_windows(ws)
  local count = windows ~= nil and #windows or 0
  local size = count > 1 and smart_border_size or 0

  if hl.get_config("general.border_size") ~= size then
    hl.config({ general = { border_size = size } })
  end
end

-- No border box around maximized/fullscreen windows (Super+Alt+F): such a
-- window covers the whole workspace, so a border line is just noise. Dynamic
-- rule: applies while the window is fullscreen (any mode), reverts the moment
-- it leaves fullscreen.
hl.window_rule({
  match = { fullscreen = true },
  border_size = 0,
})

-- Same for fake-maximized windows: the layout's Super+F fills the work area
-- and tags the window `maximized` instead of using real fullscreen, so any
-- number of windows can be maximized at once (KDE/GNOME style).
hl.window_rule({
  match = { tag = "maximized" },
  border_size = 0,
})

for _, event in ipairs({
  "window.open",             -- a window appeared
  "window.close",           -- a window is closing (may still be animating)
  "window.destroy",         -- a window fully gone (fixes count after animation)
  "window.move_to_workspace",
  "window.active",          -- focus moved (also covers workspace switches)
  "workspace.active",
  "workspace.move_to_monitor",
  "monitor.focused",
  "config.reloaded",        -- re-apply after manual config reloads
}) do
  hl.on(event, update_smart_border)
end

update_smart_border()
