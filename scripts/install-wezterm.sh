#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# https://techviewleo.com/install-wezterm-on-fedora-opensuse/?expand_article=1
source /etc/os-release
VER=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest|grep tag_name|cut -d '"' -f 4)
VER2=$(echo "$VER" | sed -r 's/-/_/g')
rpm-ostree install https://github.com/wez/wezterm/releases/download/${VER}/wezterm-${VER2}-1.fedora${VERSION_ID}.x86_64.rpm
