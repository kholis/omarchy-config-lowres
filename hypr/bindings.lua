-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Close window on SUPER+Q instead of the default SUPER+W (SUPER+W was: Close window;
-- unbound to avoid accidentally closing apps).
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Clipboard history on SUPER+SHIFT+V (default SUPER+CTRL+V unbound).
-- Ctrl variant clashed with paste-style muscle memory in some terminals.
hl.unbind("SUPER + CTRL + V")
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
-- Macbook Air
-- Disable Omarchy's default plain-F9 dictation push-to-talk, keep SUPER+F9 toggle
hl.unbind("F9")
o.bind("SUPER + F9", nil, "voxtype record toggle")

-- MacBook has no dedicated Delete key (the "delete" key sends Backspace), so
-- Omarchy's default CTRL+ALT+DELETE "Close all windows" never fires. Bind the
-- same command to CTRL+ALT+BACKSPACE (Ctrl+Alt+Mac-delete).
o.bind("CTRL + ALT + BACKSPACE", "Close all windows", "omarchy-hyprland-window-close-all")

-- MacBook has no PRINT key either. Rebind Omarchy's four PRINT-based capture
-- shortcuts to CTRL+ALT+<letter> (S=screenshot, R=recording, C=color, O=OCR).
hl.unbind("PRINT")
hl.unbind("ALT + PRINT")
hl.unbind("SUPER + PRINT")
hl.unbind("SUPER + CTRL + PRINT")
o.bind("CTRL + ALT + S", "Screenshot", "/home/kh/.local/bin/screenshot")
o.bind("CTRL + ALT + R", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")
o.bind("CTRL + ALT + C", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("CTRL + ALT + O", "Extract text (OCR) from screenshot", "omarchy-capture-text")

-- Hyper (Caps Lock) app switcher: focus the app's window on any workspace,
-- or launch it if it isn't running (wmctrl-style). Extend with more apps as needed:
-- o.bind("MOD3 + S", "Slack", { launch = "slack", focus = "slack" })
o.bind("MOD3 + A", "Terminal", { launch = "ghostty", focus = "com.mitchellh.ghostty" })
o.bind("MOD3 + B", "Brave", { launch = "brave-origin", focus = "brave-origin" })
o.bind("MOD3 + C", "Chrome", { launch = "google-chrome-stable", focus = "google-chrome" })
o.bind("MOD3 + E", "Explorer", { launch = "flea", focus = "flea" })
o.bind("MOD3 + F", "Firefox", { launch = "firefox", focus = "firefox" })
o.bind("MOD3 + M", "Teams", { webapp = "https://teams.microsoft.com/v2/?clientType=pwa", focus = true })
o.bind("MOD3 + N", "Notepadqq", { launch = "notepadqq", focus = "notepadqq" })
o.bind("MOD3 + O", "Obsidian", { launch = "obsidian", focus = "md.obsidian.Obsidian" })
o.bind("MOD3 + T", "Telegram", { launch = "Telegram", focus = "org.telegram.desktop" })
o.bind("MOD3 + U", "Outlook", { webapp = "https://outlook.cloud.microsoft/mail/", focus = true })
o.bind("MOD3 + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
o.bind("MOD3 + X", "X", { webapp = "https://x.com/", focus = true })
o.bind("MOD3 + Z", "Zoom", { launch = "zoom", focus = "zoom" })

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.
