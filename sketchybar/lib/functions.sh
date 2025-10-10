#!/usr/bin/env bash

export FONT="SF Pro" # Needs to have Regular, Bold, Semibold, Heavy and Black variants
export NERD_FONT="Liga SFMono Nerd Font"

export PADDINGS=3 # All paddings use this value (icon, label, background)

bar_config=(
  height=40
  color="$BASE"

  blur_radius=20
  corner_radius=6
  margin=7
  notch_width=0
  padding_left=10
  padding_right=10
  position=top
  shadow=on
  sticky=on
  topmost=off
  y_offset=2
)

default_config=(
  updates=when_shown

  icon.font.family="$NERD_FONT"
  icon.font.style="Semibold"
  icon.font.size=14.0
  icon.color=$WHITE
  icon.highlight_color=$GREY
  icon.padding_left=5
  icon.padding_right=5
  
  label.font.family="$NERD_FONT"
  label.font.style="Semibold"
  label.font.size=13.0
  label.color=$TEXT
  label.highlight_color=$YELLOW
  
  popup.align=right
  popup.blur_radius=10
  popup.y_offset=2
  popup.background.border_width=0
  popup.background.corner_radius=5
  popup.background.color=$BASE
  popup.background.shadow.drawing=on
)

popup_events=(
  mouse.entered
  mouse.exited
  mouse.exited.global
)

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

add_popup_item() {
  local name="$1"
  local label="$2"
  sketchybar --add item "$name" popup."$NAME" \
    --set "$name" label="$label" padding_right=10
}