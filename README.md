# omarchy-config-lowres

My [Omarchy](https://omarchy.org) configuration, tuned for **low-resolution
screens** (< Full HD — developed on a MacBook Air 1440x900) where full tiling
window management wastes more space than it saves.

Floating-first, traditional-WM feel (KDE/GNOME/XFCE style) on top of
Hyprland + Omarchy — with every window remembering its size, position and
maximized state.

```
┌──────────────────────────────────────────────────────────┐
│ menu  ▐taskbar▌      indicators  clock  weather          │  <- bar w/ taskbar plugin
├──────────────────────────────────────────────────────────┤
│   ┌─────────┐                                            │
│   │ floating│      ┌──────────────┐                      │
│   │  window │      │   floating   │   natural sizes,     │
│   └─────────┘      │    window    │   drag & overlap     │
│                    └──────────────┘                      │
│              1440x900 — no gaps, 1px smart border        │
└──────────────────────────────────────────────────────────┘
```

## What's inside

| Path | Purpose |
|---|---|
| `hypr/` | Hyprland config: MacBook bindings, caps-lock-as-Hyper, zero gaps, smart borders, low-contrast shader |
| `hypr/shaders/` | `low-contrast.frag` (xcalib-style contrast compression) + identity |
| `omarchy/shell.json` | Bar layout: taskbar, clock, tray, VPN, AI usage, network widgets |
| `omarchy/extensions/omarchy-menu.jsonc` | Omarchy menu > Workspace Layout picker |
| `omarchy/hooks/` | Theme hooks (Greybird GTK re-apply, bar text contrast), post-update hooks |
| `omarchy/themes/greybird/` | Xubuntu-style Greybird theme (backgrounds re-copied from stock Omarchy at install) |
| `omarchy/plugins/io.github.kholis.gp-vpn` | My GlobalProtect VPN bar widget (vendored) |
| `omarchy/plugins/kh.notifications` | My notification daemon customization (vendored) |
| `bin/` | `contrast`, `screenshot` (true-color capture bypassing the shader), `chrome-open-tab`, `use-omarchy`/`use-xfce` session switchers, `restart-globalprotect.sh` |
| `config/ghostty/` | Ghostty terminal tuned for 1440x900 (9pt font, no CSD) |
| `install.sh` | Portable idempotent installer |

Referenced, not vendored (installed by `install.sh`):

- [kholis/hyprland-layout](https://github.com/kholis/hyprland-layout) — the
  workspace layout engine (`workspaces.lua`): four modes, window state memory,
  Alt+Tab MRU switcher, menu integration.
- [kholis/omarchy-taskbar](https://github.com/kholis/omarchy-taskbar) — my fork
  of [joeyvigil/omarchy-taskbar](https://github.com/joeyvigil/omarchy-taskbar),
  the recommended taskbar plugin (see below).

## Floating layout by default

Small screens need every pixel. Instead of tiling, the default `float` mode
works like a traditional WM:

- every app opens **floating at its natural size** on the current workspace
- drag, resize, overlap freely; snap to screen halves with `Hyper+arrows`
- `Super+F` maximizes KDE/GNOME-style (multiple windows can be maximized)
- `Alt+Tab` switches between **all** windows on **all** workspaces (MRU);
  `Hyper+Tab` stays local
- click-to-focus — hovering never steals focus
- **window state memory**: sizes, positions and maximized/fullscreen state
  survive lock screen / suspend / app restarts

Cycle modes with **Caps Lock + Space** (own → float → stacked → tiling) or via
**Omarchy menu > Trigger > Toggle > Workspace Layout**, or
`hyprland-layout-set <mode>` in a terminal. The `own` mode gives each app its
own workspace; `stacked` monocle-stacks everything maximized on workspace 1;
`tiling` is stock dwindle for purists.

## Recommended plugin: taskbar (traditional WM style)

The one thing tiling WMs never had and KDE/GNOME users miss: a real taskbar.
[**omarchy-taskbar**](https://github.com/kholis/omarchy-taskbar) (my fork of
joeyvigil's) pins app icons in the Omarchy bar, marks running apps in open
order with a dot on the active one, and pins/unpins right from the bar —
exactly the GNOME/KDE dock+taskbar experience. Installed and enabled
automatically by `install.sh`; manual install:

```bash
omarchy plugin add https://github.com/kholis/omarchy-taskbar.git
```

Other bar plugins this config uses (installed with `install.sh`, skipped by
`--minimal`): `akitaonrails/ai-usagebar` (AI token usage), `ArtMin96/omarchy-l2tp-vpn`,
`faperac/omarchy-displays`.

## MacBook shortcuts

MacBooks lack `Print` and `Delete`, and Caps Lock earns its keep as a **Hyper
modifier** (`caps:hyper`; real Caps = both Shifts together).

### Window / layout

| Keys | Action |
|---|---|
| `Caps+Space` (Hyper+Space) | Cycle layout: own / float / stacked / tiling |
| `Super+F` | Maximize window (KDE-style, multiple allowed) |
| `Super+Alt+F` | Real fullscreen |
| `Hyper+arrows` | Snap floating window to screen half |
| `Alt+Tab` / `Hyper+Tab` | Switch window: all workspaces MRU / current workspace |
| `Super+1..9`, `Super+Shift+1..9` | Go to workspace / move window to workspace |
| `Super+Q` | Close window (rebound from `Super+W` — no more accidental closes) |
| `Ctrl+Alt+Backspace` | Close all windows (MacBook has no Delete key) |

### Capture (no Print key on MacBook)

| Keys | Action |
|---|---|
| `Ctrl+Alt+S` | Screenshot (`~/.local/bin/screenshot` — true colors, shader bypassed) |
| `Ctrl+Alt+R` | Toggle screen recording |
| `Ctrl+Alt+C` | Color picker (hyprpicker) |
| `Ctrl+Alt+O` | OCR text from screenshot |

### Hyper (Caps Lock) app switcher — launch or focus

| Key | App | Key | App |
|---|---|---|---|
| `Caps+A` | Ghostty terminal | `Caps+O` | Obsidian |
| `Caps+B` | Brave | `Caps+T` | Telegram |
| `Caps+C` | Chrome | `Caps+U` | Outlook (webapp) |
| `Caps+E` | Flea file manager | `Caps+W` | WhatsApp (webapp) |
| `Caps+F` | Firefox | `Caps+X` | X (webapp) |
| `Caps+M` | Teams (webapp) | `Caps+Z` | Zoom |
| `Caps+N` | Notepadqq | | |

### Misc

| Keys | Action |
|---|---|
| `Super+Shift+V` | Clipboard manager (rebound from `Super+Ctrl+V`) |
| `Super+Shift+F` / `Super+Alt+Shift+F` | File manager / file manager at cwd |
| `Super+F9` | Voxtype voice dictation toggle |
| `Shift+Insert` / `Ctrl+Insert` | Paste / copy (Ghostty) |

## Low-resolution tuning

- **Zero gaps**, 1px border only when 2+ windows share a workspace (smart
  borders — a lone window renders borderless)
- **Low-contrast screen shader** (`contrast 0.9` at login, ≈ `xcalib -co 90`)
  — pulls whites down on the glossy panel; `contrast <0.5-1.0>` to tune,
  `contrast off` to disable
- Ghostty at **9pt** JetBrainsMono, bar font 12, `GDK_SCALE=2` env for crisp
  GTK apps
- Greybird theme: light GTK, compact XFCE-style widgets, `Noto Sans 9`
- Screenshot capture temporarily bypasses the shader so images keep true colors

## Deploy on a new Omarchy device

```bash
git clone https://github.com/kholis/omarchy-config-lowres.git
cd omarchy-config-lowres
./install.sh              # full install
# ./install.sh --minimal  # skip third-party bar plugins
# ./install.sh --no-theme # don't switch to greybird
```

The installer:

1. backs up every replaced file as `<name>.bak.<timestamp>` (idempotent —
   safe to re-run; restore by copying a `.bak` file back)
2. deploys `hypr/` + shaders (rewrites `/home/kh` paths to your `$HOME`)
3. installs [hyprland-layout](https://github.com/kholis/hyprland-layout)
   (pinned ref; `LAYOUT_REF=main ./install.sh` to track main)
4. deploys bar layout, menu, hooks, Greybird theme (+ stock backgrounds), my
   plugins
5. installs the taskbar plugin from my fork + third-party bar plugins
6. applies the theme, restarts the Omarchy shell, reloads Hyprland

Requires Omarchy 4.x on Hyprland 0.55+ (Lua config helpers).

## Privacy note

This is a public backup of my personal config. Shipped values are scrubbed:
the clock's `birthYear`/`lifeExpectancy` and the GlobalProtect portal hostname
are empty in the repo (my live config keeps them). SSH aliases with credentials
are intentionally excluded.

## License

MIT — see [LICENSE](LICENSE).
