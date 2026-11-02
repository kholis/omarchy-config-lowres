#!/usr/bin/env bash
# omarchy-config-lowres installer
# https://github.com/kholis/omarchy-config-lowres
#
# Deploys an Omarchy configuration tuned for low-resolution screens
# (< Full HD, e.g. a 1440x900 MacBook) with a floating-workspace default
# layout and a traditional-WM taskbar.
#
# Usage:
#   ./install.sh              full install (recommended plugins included)
#   ./install.sh --minimal    skip third-party bar plugins (taskbar still installed)
#   ./install.sh --no-theme   do not run `omarchy theme set greybird`
#
# Safe to re-run: every replaced file is backed up as <name>.bak.<timestamp>.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="${HOME}/.config/hypr"
OMA_DIR="${HOME}/.config/omarchy"
BIN_DIR="${HOME}/.local/bin"
STAMP="$(date +%s)"

# Pinned refs for reproducible deploys; override via env to track main.
LAYOUT_REPO="https://github.com/kholis/hyprland-layout.git"
LAYOUT_REF="${LAYOUT_REF:-e3aaae2}"
TASKBAR_REPO="https://github.com/kholis/omarchy-taskbar.git"

MINIMAL=0
SET_THEME=1
for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=1 ;;
    --no-theme) SET_THEME=0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warning:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- preflight ----------------------------------------------------------------
[ -d /usr/share/omarchy ] || [ -n "${OMARCHY_PATH:-}" ] \
  || die "Omarchy not found. This config targets Omarchy (https://omarchy.org)."
command -v hyprctl >/dev/null 2>&1 \
  || warn "hyprctl not found - install anyway, reload at next Hyprland session."
[ "$(id -u)" -eq 0 ] && die "run as your user, not root."

backup() { # backup <file>
  [ -f "$1" ] || return 0
  cp "$1" "$1.bak.${STAMP}"
  say "backed up $1 -> $(basename "$1").bak.${STAMP}"
}

# --- 1. Hyprland config (floating-first look'n'feel, MacBook bindings) --------
say "deploying Hyprland config -> ${HYPR_DIR}"
mkdir -p "${HYPR_DIR}/shaders"
for f in "${REPO_DIR}"/hypr/*.lua "${REPO_DIR}"/hypr/*.conf; do
  [ -e "$f" ] || continue
  backup "${HYPR_DIR}/$(basename "$f")"
  # Repo files may carry absolute /home/<user> paths; make them portable.
  sed "s|/home/kh|${HOME}|g" "$f" > "${HYPR_DIR}/$(basename "$f")"
done
for f in "${REPO_DIR}"/hypr/shaders/*.frag; do
  cp "$f" "${HYPR_DIR}/shaders/$(basename "$f")"
done

# --- 2. hyprland-layout (floating/own/stacked/tiling workspaces.lua) ----------
say "installing hyprland-layout (${LAYOUT_REF})"
LAYOUT_TMP="$(mktemp -d)"
git clone --quiet "${LAYOUT_REPO}" "${LAYOUT_TMP}"
git -C "${LAYOUT_TMP}" checkout --quiet "${LAYOUT_REF}"
# Its install.sh deploys hypr/workspaces.lua, bin/hyprland-layout-set and the
# Omarchy menu fragment; it detects existing configs and never duplicates.
"${LAYOUT_TMP}/install.sh"
rm -rf "${LAYOUT_TMP}"

# --- 3. Omarchy shell config (bar layout, menu, hooks, greybird theme) --------
say "deploying Omarchy shell config -> ${OMA_DIR}"
mkdir -p "${OMA_DIR}/extensions" "${OMA_DIR}/hooks/theme-set.d" \
         "${OMA_DIR}/hooks/post-update.d" "${OMA_DIR}/themes" \
         "${OMA_DIR}/plugins" "${OMA_DIR}/branding" "${OMA_DIR}/defaults"

backup "${OMA_DIR}/shell.json"
cp "${REPO_DIR}/omarchy/shell.json" "${OMA_DIR}/shell.json"
backup "${OMA_DIR}/shell.toml"
cp "${REPO_DIR}/omarchy/shell.toml" "${OMA_DIR}/shell.toml"
backup "${OMA_DIR}/extensions/omarchy-menu.jsonc"
cp "${REPO_DIR}/omarchy/extensions/omarchy-menu.jsonc" "${OMA_DIR}/extensions/"

cp "${REPO_DIR}/omarchy/branding/"* "${OMA_DIR}/branding/"
cp "${REPO_DIR}/omarchy/defaults/"* "${OMA_DIR}/defaults/"
cp "${REPO_DIR}/omarchy/hooks/theme-set.d/"* "${OMA_DIR}/hooks/theme-set.d/"
cp "${REPO_DIR}/omarchy/hooks/post-update.d/"* "${OMA_DIR}/hooks/post-update.d/"
chmod +x "${OMA_DIR}/hooks/theme-set.d/"* "${OMA_DIR}/hooks/post-update.d/"*

# --- 4. Own plugins (no upstream git repo; vendored here) ---------------------
for plugin in io.github.kholis.gp-vpn kh.notifications; do
  if [ -d "${OMA_DIR}/plugins/${plugin}" ]; then
    warn "plugin ${plugin} already installed - keeping your copy"
  else
    cp -r "${REPO_DIR}/omarchy/plugins/${plugin}" "${OMA_DIR}/plugins/"
    say "installed plugin ${plugin}"
  fi
done

# --- 5. Bar plugins from git (taskbar + third-party) --------------------------
plugin_add() { # plugin_add <url> <id>
  if [ -d "${OMA_DIR}/plugins/$2" ]; then
    say "plugin $2 already present - skipping"
  elif command -v omarchy >/dev/null 2>&1; then
    omarchy plugin add "$1" --yes && say "installed plugin $2 from $1"
  else
    warn "omarchy CLI missing - install $2 manually: omarchy plugin add $1"
  fi
}

say "installing taskbar plugin (traditional-WM style, from my fork)"
plugin_add "${TASKBAR_REPO}" "io.github.joeyvigil.taskbar"

if [ "${MINIMAL}" -eq 0 ]; then
  say "installing third-party bar plugins"
  plugin_add "https://github.com/akitaonrails/ai-usagebar.git"       "akitaonrails.ai-usagebar"
  plugin_add "https://github.com/ArtMin96/omarchy-l2tp-vpn.git"      "artmins96.l2tp"
  plugin_add "https://github.com/faperac/omarchy-displays.git"       "faperac.displays"
fi

# --- 6. Helper scripts ---------------------------------------------------------
say "deploying helper scripts -> ${BIN_DIR}"
mkdir -p "${BIN_DIR}"
for f in "${REPO_DIR}"/bin/*; do
  sed "s|/home/kh|${HOME}|g" "$f" > "${BIN_DIR}/$(basename "$f")"
  chmod +x "${BIN_DIR}/$(basename "$f")"
done

# --- 7. Greybird theme (backgrounds are stock Omarchy art, not vendored) ------
say "installing greybird theme"
mkdir -p "${OMA_DIR}/themes/greybird"
cp -r "${REPO_DIR}/omarchy/themes/greybird/." "${OMA_DIR}/themes/greybird/"
if [ ! -d "${OMA_DIR}/themes/greybird/backgrounds" ]; then
  STOCK_BG="$(ls -d /usr/share/omarchy/themes/*/backgrounds 2>/dev/null | head -1 || true)"
  if [ -n "${STOCK_BG}" ]; then
    cp -r "${STOCK_BG}" "${OMA_DIR}/themes/greybird/backgrounds"
    say "copied stock backgrounds from ${STOCK_BG}"
  else
    warn "no stock Omarchy backgrounds found - greybird will fall back to plain color"
  fi
fi

# --- 8. Apply ------------------------------------------------------------------
if [ "${SET_THEME}" -eq 1 ] && command -v omarchy >/dev/null 2>&1; then
  omarchy theme set greybird || warn "omarchy theme set failed - run it manually"
fi
command -v omarchy >/dev/null 2>&1 && omarchy restart shell >/dev/null 2>&1 || true
command -v hyprctl  >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true

# --- done -----------------------------------------------------------------------
say "done. Restore anything with the .bak.${STAMP} files next to the originals."
cat <<'EOF'

Next steps / notes:
  - Layout defaults to FLOAT (traditional WM: KDE/GNOME/XFCE feel). Cycle with
    Caps Lock + Space, or Omarchy menu > Trigger > Toggle > Workspace Layout.
  - shell.json ships scrubbed: add your clock birthYear/lifeExpectancy back in
    ~/.config/omarchy/shell.json if you want the life-in-weeks clock.
  - The GlobalProtect VPN widget defaults to portal "" - set your portal via
    the bar widget settings (right-click) or ~/.config/omarchy/shell.json.
  - Screenshot/recording keys moved off PRINT (MacBooks have none):
    Ctrl+Alt+S screenshot, Ctrl+Alt+R recording, Ctrl+Alt+C color picker,
    Ctrl+Alt+O OCR. Caps Lock acts as Hyper for app switching (Caps+letter).
EOF
