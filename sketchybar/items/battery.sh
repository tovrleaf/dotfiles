#!/usr/bin/env bash

source "lib/functions.sh"

battery=(
  update_freq=1
  script="$PLUGIN_DIR/battery.sh"
)

battery_details=(
	background.corner_radius=12
	background.padding_left=5
	background.padding_right=15
	icon.background.height=2
	icon.background.y_offset=-12
)

sketchybar -m --add item battery right \
  --set battery "${battery[@]}" \
  --subscribe battery "${popup_events[@]}" mouse.clicked \
  \
  --add item battery.details popup.battery  \
  --set battery.details "${battery_details[@]}"   