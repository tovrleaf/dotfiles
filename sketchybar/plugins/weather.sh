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
  sketchybar --set weather.temp label="$icon $temp""°" label.padding_left=2
}

render_popup() {
  sketchybar --remove '/weather.details.\.*/'

  # Helsinki hourly forecast popup for 3 days
  COUNTER=0
  
  for day_idx in 0 1 2; do
    full_date=$(echo "$weather" | jq -r ".weather[$day_idx].date")
    date=$(echo "$full_date" | cut -d'-' -f3,2 | tr '-' '.')
    weekday=$(date -j -f "%Y-%m-%d" "$full_date" "+%a" 2>/dev/null || echo "")
    
    # Add day header
    day_header=(
      label="--- $weekday $date ---"
      click_script="sketchybar --set $NAME popup.drawing=off"
      padding_right=10
      drawing=on
    )
    item=weather.details."$COUNTER"
    sketchybar --add item "$item" popup.weather.temp
    sketchybar --set "$item" "${day_header[@]}"
    COUNTER=$((COUNTER + 1))
    
    for hour_idx in {0..23}; do
      time_raw=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].time // empty")
      [ -z "$time_raw" ] && continue
      
      time=$((time_raw / 100))
      temp=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].tempC")
      desc=$(echo "$weather" | jq -r ".weather[$day_idx].hourly[$hour_idx].weatherDesc[0].value")
    
      # Determine if it's day or night for this hour
      sunrise_hour=$(echo "$sunrise" | sed 's/:.*//' | sed 's/AM//g' | sed 's/PM//g')
      sunset_hour=$(echo "$sunset" | sed 's/:.*//' | sed 's/AM//g' | sed 's/PM//g')
      [[ "$sunset" == *"PM"* ]] && [[ ! "$sunset" == "12:"* ]] && sunset_hour=$((sunset_hour + 12))
      
      if [ "$time" -ge "$sunrise_hour" ] && [ "$time" -lt "$sunset_hour" ]; then
        is_day="true"
      else
        is_day="false"
      fi
      
      hour_icon=$(weather_icon_map "$is_day" "$desc")
      [ -z "$hour_icon" ] && hour_icon="🌤️"
      
      # Format time as 12-hour format
      if [ "$time" -eq 0 ]; then
        formatted_time="12am"
      elif [ "$time" -lt 12 ]; then
        formatted_time="${time}am"
      elif [ "$time" -eq 12 ]; then
        formatted_time="12pm"
      else
        formatted_time="$((time - 12))pm"
      fi

      weather_period=(
        label="  $hour_icon $formatted_time: $desc ${temp}C"
        click_script="sketchybar --set $NAME popup.drawing=off"
        padding_right=10
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
  url="https://wttr.in/Helsinki?format=j1"
  weather=$(curl -s "$url")
  temp=$(echo "$weather" | jq -r '.current_condition[0].temp_C // "--"')
  forecast=$(echo "$weather" | jq -r '.current_condition[0].weatherDesc[0].value // "Unknown"')

  sunrise=$(echo "$weather" | jq -r '.weather[0].astronomy[0].sunrise // "06:00AM"')
  sunset=$(echo "$weather" | jq -r '.weather[0].astronomy[0].sunset // "06:00PM"')

  icon=$(weather_icon_map "$time" "$forecast")

  # Convert times to minutes since midnight for comparison
  current_minutes=$(date +%H%M)
  sunrise_minutes=$(echo "$sunrise" | sed 's/://g' | sed 's/AM//g' | sed 's/PM//g')
  sunset_minutes=$(echo "$sunset" | sed 's/://g' | sed 's/AM//g' | sed 's/PM//g')

  # Adjust PM times (add 1200 if PM and not 12 PM)
  if [[ "$sunset" == *"PM"* ]] && [[ ! "$sunset" == "12:"* ]]; then
    sunset_minutes=$((sunset_minutes + 1200))
  fi

  if [ "$current_minutes" -ge "$sunrise_minutes" ] && [ "$current_minutes" -lt "$sunset_minutes" ]; then
    time="true"  # sun is up
  else
    time="false" # sun is down
  fi

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