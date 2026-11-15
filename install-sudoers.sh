#!/bin/bash
# Installs /etc/sudoers.d/stayawake, which lets StayAwake run only its seven pmset commands
# without a password. Asks for your password once. Remove with: sudo rm /etc/sudoers.d/stayawake
set -euo pipefail
cd "$(dirname "$0")"

USER_NAME="${SUDO_USER:-$(id -un)}"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

sed "s/__USER__/$USER_NAME/g" Resources/sudoers-stayawake > "$TMP"
/usr/sbin/visudo -cf "$TMP" >/dev/null       # refuse to install a rule that doesn't parse

sudo /usr/bin/install -m 0440 -o root -g wheel "$TMP" /etc/sudoers.d/stayawake
sudo /usr/sbin/visudo -c >/dev/null           # whole sudoers config still valid
echo "Installed /etc/sudoers.d/stayawake for $USER_NAME."
