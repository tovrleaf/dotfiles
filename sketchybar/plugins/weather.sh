#!/usr/bin/env bash

source "lib/colors.sh"
source "lib/functions.sh"

# False = night
# True = daytime
weather_icon_map() {
  shopt -s extglob
  # check if first argument is true or false to determine whether day or night
  # then check if second argument wildcard contains a string for determining which icon to sho
  # if no match, return default icon
  if [ "$1" = "true" ]; then # Daytime
  	case $2 in
      *Snow*)
        icon_result="🌨️"
        ;;
      *Rain*)
        icon_result="🌧️"
        ;;
      *"Partly Sunny"* | *"Partly Cloudy"*)
        icon_result="⛅"
        ;;
      *Sunny* | *Clear*)
        icon_result="☀️"
  			;;
      *Cloudy*)
        icon_result="☁️"
        ;;
      *)
        icon_result="🌤️"
        ;;
    esac
  else
    case $2 in # Night
      *Snow*)
        icon_result="🌨️"
        ;;
      *Rain*)
        icon_result="🌧️"
        ;;
      *Clear*)
        icon_result="🌜"
        ;;
      *Cloudy*)
        icon_result="☁️"
        ;;
      *Fog*)
        icon_result="🌫️"
        ;;
      *)
        icon_result="🌜"
        ;;
    esac
  fi
  echo $icon_result
}

render_bar() {
  sketchybar --set weather.icon icon="$icon" icon.font.size=10.0 icon.padding_right=2
  sketchybar --set weather.temp label="${icon}${temp}""°" label.padding_left=2
}

render_popup() {
  sketchybar --remove '/weather.details.\.*/'

  COUNTER=0
  current_hour=$(date +%H)
  day_header_added=false
  
  for day_idx in 0 1; do
    for hour_idx in {0..23}; do
      time_raw=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].time // empty")
      [ -z "$time_raw" ] && continue
      
      time=$((time_raw / 100))
      
      # For today, find the current or next 3-hour interval
      if [ "$day_idx" -eq 0 ]; then
        # Find the current 3-hour interval (0, 3, 6, 9, 12, 15, 18, 21)
        current_interval=$((current_hour / 3 * 3))
        if [ "$time" -lt "$current_interval" ]; then
          continue
        fi
      fi
      
      # Stop after 16 datapoints
      if [ "$COUNTER" -ge 16 ]; then
        break 2
      fi
      
      # Add day header when switching days
      if [ "$day_idx" -eq 1 ] && [ "$day_header_added" = false ]; then
        day_header=(
          label="--- Tomorrow ---"
          click_script="sketchybar --set $NAME popup.drawing=off"
          padding_right=10
          drawing=on
        )
        item=weather.details."$COUNTER"
        sketchybar --add item "$item" popup.weather.temp
        sketchybar --set "$item" "${day_header[@]}"
        COUNTER=$((COUNTER + 1))
        day_header_added=true
        
        # Stop if we've reached 16 items including the header
        if [ "$COUNTER" -ge 16 ]; then
          break 2
        fi
      fi
      
      temp=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].tempC // \"--\"")
      desc=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].weatherDesc[0].value")
    
      # Determine if it's day or night for this hour
      if [ "$time" -ge 6 ] && [ "$time" -lt 18 ]; then
        is_day="true"
      else
        is_day="false"
      fi
      
      hour_icon=$(weather_icon_map "$is_day" "$desc")
      [ -z "$hour_icon" ] && hour_icon="🌤️"
      
      # Format time as 12-hour format with fixed width
      if [ "$time" -eq 0 ]; then
        formatted_time="12am"
      elif [ "$time" -lt 12 ]; then
        formatted_time="${time}am"
      elif [ "$time" -eq 12 ]; then
        formatted_time="12pm"
      else
        formatted_time="$((time - 12))pm"
      fi
      
      # Pad temperature to fixed width (3 chars)
      temp_padded=$(printf "%3s" "$temp")
      # Pad time to fixed width (4 chars, right-aligned)
      time_padded=$(printf "%4s" "$formatted_time")

      weather_period=(
        label="  $hour_icon ${temp_padded}° $time_padded $desc"
        click_script="sketchybar --set $NAME popup.drawing=off"
        padding_right=10
        label.width=300
        drawing=on
      )

      item=weather.details."$COUNTER"
      sketchybar --add item "$item" popup.weather.temp
      sketchybar --set "$item" "${weather_period[@]}"
      COUNTER=$((COUNTER + 1))
    done
  done
}

update() {
  # Bar
  url="https://wttr.in/?format=j1"
  weather=$(curl -s "$url")
  temp=$(echo "$weather" | jq -r '.current_condition[0].temp_C // "--"')
  forecast=$(echo "$weather" | jq -r '.current_condition[0].weatherDesc[0].value // "Unknown"')

  # Use local sunrise/sunset times (approximate)
  current_hour=$(date +%H)
  if [ "$current_hour" -ge 6 ] && [ "$current_hour" -lt 18 ]; then
    time="true"  # sun is up (6 AM - 6 PM)
  else
    time="false" # sun is down
  fi

  icon=$(weather_icon_map "$time" "$forecast")



  render_bar
  render_popup

  if [ "$COUNT" -ne "$PREV_COUNT" ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
    sketchybar --animate tanh 15 --set "$NAME" label.y_offset=5 label.y_offset=0
  fi
}

case "$SENDER" in
"routine" | "forced")
	update
	;;
"mouse.entered")
	popup on
	;;
"mouse.exited" | "mouse.exited.global")
	popup off
	;;
"mouse.clicked")
	popup toggle
	;;
esac