#!/usr/bin/env bash

source "lib/functions.sh"

brew=(
  icon=􀐛
  update_freq=300
  script="$PLUGIN_DIR/brew.sh"
)

sketchybar --add item brew right \
  --set brew "${brew[@]}" \
  --subscribe brew "${popup_events[@]}" mouse.clicked