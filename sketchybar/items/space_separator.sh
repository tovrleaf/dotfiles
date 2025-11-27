#!/usr/bin/env bash

source "lib/functions.sh"

sketchybar --add item space_separator right \
  --set space_separator icon="|" \
  icon.color="$OVERLAY2" \
  icon.padding_left=0 \
  icon.padding_right=12 \
  label.drawing=off \
  background.drawing=off