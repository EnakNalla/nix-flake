#!/bin/bash

calendar=(
  icon=cal
  icon.font="$FONT:Black:12.0"
  label.align=right
  update_freq=1
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right \
  --set calendar "${calendar[@]}" \
  --subscribe calendar system_woke
