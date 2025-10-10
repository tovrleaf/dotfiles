#!/usr/bin/env bash

source "lib/functions.sh"

date=(
  label=date
	label.font="$FONT:Bold:12.0"
	label.align=right
	label.padding_right=0
	width=35
	y_offset=6
	update_freq=120
	script="$PLUGIN_DIR/date.sh"
)

time=(
  label=time
	label.font="$FONT:Bold:12.0"
	label.align=right
	label.padding_right=0
	background.padding_right=-35
	background.padding_left=38
	y_offset=-8
	update_freq=15
	script="$PLUGIN_DIR/time.sh"
)

# @TODO Add on click zen

sketchybar --add item clock.date right \
  --set clock.date "${date[@]}" \
  --subscribe clock.date system_woke \
  \
  --add item calendar.time right \
  --set calendar.time "${time[@]}" \
  --subscribe calendar.time system_woke