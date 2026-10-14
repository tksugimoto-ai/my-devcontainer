#!/bin/sh
# Runs as root at build time. The whole feature folder is copied into the
# container, so statusline.sh sits next to this script — the workspace is NOT
# mounted yet, and nothing here may reference it.
set -e
cd "$(dirname "$0")"

# jq parses the status line JSON; tzdata backs the TZ set in devcontainer.json.
# Both ship in the devcontainer base images, so this normally does nothing.
if ! command -v jq >/dev/null || [ ! -d /usr/share/zoneinfo ]; then
  apt-get update
  apt-get install -y --no-install-recommends jq tzdata
  rm -rf /var/lib/apt/lists/*
fi

# Nothing goes under ~/.claude: that dir is a persisted volume
# (claude-config-volume), which hides whatever the image puts there, and its
# settings.json belongs to the user. The script lives in /usr/local/share and
# the settings go in as a managed-settings drop-in, which Claude Code layers on
# top of the user's settings (hooks from both run) and which is rebuilt along
# with the image.
dest=/usr/local/share/claude-code-statusline
mkdir -p "$dest" /etc/claude-code/managed-settings.d
install -m 755 statusline.sh "$dest/"
install -m 644 claude-settings.json /etc/claude-code/managed-settings.d/claude-code-statusline.json
