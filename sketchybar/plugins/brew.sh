#!/usr/bin/env bash

source "lib/colors.sh"
source "lib/functions.sh"

refresh() {
  # Show loading state immediately
  sketchybar --set "$NAME" icon.color="$YELLOW" label="..."
  
  # Check outdated packages without updating first (faster)
  OUTDATED=$(brew outdated --quiet 2>/dev/null)
  COUNT=$(echo "$OUTDATED" | wc -l | tr -d ' ')
  
  # Clear existing popup items
  sketchybar --remove '/brew.popup\.*/' 2>/dev/null
  
  if [ -z "$OUTDATED" ]; then
    sketchybar --set "$NAME" icon.color="$GREEN" label="􀆅"
    # Update in background for next check
    brew update &>/dev/null &
    return
  fi

  # Set color based on count
  case "$COUNT" in
    [3-9][0-9]*) COLOR="$RED" ;;
    [1-2][0-9]) COLOR="$PEACH" ;;
    [1-9]) COLOR="$YELLOW" ;;
    *) COLOR="$GREEN" ;;
  esac

  # Add popup items
  local args=()
  local counter=0
  while IFS= read -r package; do
    [ -n "$package" ] || continue
    args+=(--add item "$NAME.popup.$counter" popup."$NAME"
           --set "$NAME.popup.$counter" label="$package" padding_right=10)
    ((counter++))
  done <<< "$OUTDATED"
  
  sketchybar "${args[@]}" --set "$NAME" icon.color="$COLOR" label.color="$COLOR" label="$COUNT"
  
  # Update in background for next check
  brew update &>/dev/null &
}

update() {
  # Show updating state
  sketchybar --set "$NAME" icon.color="$YELLOW" label="..."
  
  # Run upgrade in terminal
  osascript -e 'tell application "Terminal" to do script "brew upgrade && brew cleanup && echo \"Update complete. Press any key to close...\" && read"'
  
  # Refresh after a delay to show updated state
  (sleep 2 && sketchybar --trigger brew_refresh) &
}

case "$SENDER" in
  "routine" | "forced" | "brew_refresh")
    refresh
    ;;
  "mouse.entered")
    popup on
    ;;
  "mouse.exited" | "mouse.exited.global")
    popup off
    ;;
  "mouse.clicked")
    popup off
    update
    ;;
esac