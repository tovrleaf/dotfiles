#!/usr/bin/env bash

DAY=$(date '+%d')
MONTH=$(date '+%m')
sketchybar --set "$NAME" label="$(printf '%s\n%s' "$DAY" "$MONTH")"
