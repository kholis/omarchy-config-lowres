#!/bin/bash

# Re-apply the Xubuntu-style Greybird GTK look after an Omarchy theme change.
# omarchy-theme-set-gnome resets gtk-theme/icon-theme/color-scheme to match the
# Omarchy theme; this hook restores Greybird, elementary-xfce icons and the
# Noto Sans 9 font for GTK apps. Omarchy's own font (JetBrainsMono) and colors
# are untouched - this only affects GTK/Qt applications.

if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  exit 0
fi

gsettings set org.gnome.desktop.interface gtk-theme "Greybird"
gsettings set org.gnome.desktop.interface icon-theme "elementary-xfce"
gsettings set org.gnome.desktop.interface font-name "Noto Sans Regular 9"
gsettings set org.gnome.desktop.interface color-scheme "prefer-light"

# Font rendering: anti-aliasing (subpixel), slight hinting, RGB subpixel order.
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface font-hinting "slight"
gsettings set org.gnome.desktop.interface font-rgba-order "rgb"
