#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

ln -sf ~/.config/Brewfile ~/Brewfile
ln -sf ~/.config/.gitconfig ~/.gitconfig
ln -sf ~/.config/.gitconfig.work ~/.gitconfig.work
