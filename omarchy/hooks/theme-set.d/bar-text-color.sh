#!/bin/bash
# Theme-aware bar text contrast.
#
# Rewrites the [bar] text color in ~/.config/omarchy/shell.toml so it
# follows the active theme:
#   - dark themes  -> fixed #dfe4f8 (brighter than any palette's
#                     bright_foreground, e.g. Tokyo Night's #c0caf5)
#   - light themes -> the palette's (already dark) foreground
#
# Runs after `omarchy theme set` (see omarchy-theme-set), when the merged
# palette is already installed at ~/.local/state/omarchy/current/theme/.
# The omarchy shell watches shell.toml and reloads it live — no restart.
# Idempotent: re-running with the same theme produces the same file.

set -u

SHELL_TOML="$HOME/.config/omarchy/shell.toml"
COLORS="${OMARCHY_BAR_TEXT_COLORS:-$HOME/.local/state/omarchy/current/theme/colors.toml}"

[[ -f $COLORS ]] || exit 0

toml_color() {
  grep -E "^[[:space:]]*$1[[:space:]]*=" "$COLORS" | head -n1 | sed -E 's/.*"([^"]+)".*/\1/'
}

mode=$(grep -E '^[[:space:]]*mode[[:space:]]*=' "$COLORS" | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
foreground=$(toml_color foreground)

# Fallback when mode is missing: a light foreground implies a dark theme.
if [[ -z $mode && $foreground =~ ^#[0-9A-Fa-f]{6}$ ]]; then
  r=$((16#${foreground:1:2})) g=$((16#${foreground:3:2})) b=$((16#${foreground:5:2}))
  if (( r*299 + g*587 + b*114 > 128000 )); then mode=dark; else mode=light; fi
fi

if [[ $mode == dark ]]; then color="#dfe4f8"; else color=$foreground; fi

[[ $color =~ ^#[0-9A-Fa-f]{6}$ ]] || exit 0

mkdir -p "$(dirname "$SHELL_TOML")"
touch "$SHELL_TOML"

# Section-aware edit: replace text = "..." inside [bar] only, keep the rest
# (e.g. [font] base-size written by `omarchy display text size`). Insert the
# key if the section lacks it; append a [bar] section only when absent.
awk -v color="$color" '
  BEGIN { inbar = 0; done = 0 }
  /^\[bar\]/ { inbar = 1; print; next }
  /^\[/ {
    if (inbar && !done) { print "text = \"" color "\""; done = 1 }
    inbar = 0; print; next
  }
  inbar && /^[[:space:]]*text[[:space:]]*=/ { print "text = \"" color "\""; done = 1; next }
  { print }
  END {
    if (!done) {
      if (!inbar) print "[bar]"
      print "text = \"" color "\""
    }
  }
' "$SHELL_TOML" > "$SHELL_TOML.tmp" && mv "$SHELL_TOML.tmp" "$SHELL_TOML"

exit 0
