#!/usr/bin/env bash

source "lib/functions.sh"

time=(
  label=time
	label.font="CPMono_v07:Plain:24.0"
	label.align=right
	background.padding_right=-35
	y_offset=0
	update_freq=15
	script="$PLUGIN_DIR/time.sh"
)

date_day=(
  label=date_day
  label.font="CPMono_v07:Bold:11.0"
  label.align=center
  width=25
  y_offset=5
  background.padding_right=0
  update_freq=120
  script="$PLUGIN_DIR/date_day.sh"
)

date_month=(
  label=date_month
	label.font="CPMono_v07:Bold:11.0"
	label.align=center
	width=25
	y_offset=-5
	background.padding_right=-25
	update_freq=120
	script="$PLUGIN_DIR/date_month.sh"
)

# @TODO Add on click zen

sketchybar \
  --add item clock.date_day right \
  --set clock.date_day "${date_day[@]}" \
  --subscribe clock.date_day system_woke \
  --add item clock.date_month right \
  --set clock.date_month "${date_month[@]}" \
  --subscribe clock.date_month system_woke \
  --add item calendar.time right \
  --set calendar.time "${time[@]}" \
  --subscribe calendar.time system_woke \
