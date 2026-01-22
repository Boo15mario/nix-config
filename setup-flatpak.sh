#!/bin/sh
if [ "$(id -un)" != "root" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak install -y flathub io.github.realmazharhussain.GdmSettings
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub com.google.Chrome
