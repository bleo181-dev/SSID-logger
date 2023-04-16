#!/bin/bash

# Name of the Wi-Fi networks log file
LOG_FILE="log_wifi.txt"

# Array to store registered SSIDs with timestamps
declare -A registered_ssids

# Function to create the log file if it does not exist
create_log_file() {
  if [[ ! -e "$LOG_FILE" ]]; then
    echo "--------- + $(date "+%Y-%m-%d %H:%M:%S") + New SSID logging + --------" > "$LOG_FILE"
  fi
}

# "Restart" the log file if it exists
if [[ -s "$LOG_FILE" ]]; then
  echo "--------- + $(date "+%Y-%m-%d %H:%M:%S") + New SSID logging + --------" >> "$LOG_FILE"
fi

# Check if the log file exists
create_log_file

# Continuous loop for Wi-Fi network logging
while true; do
  # Detect surrounding Wi-Fi networks
  iw_output=$(sudo iw dev wlan0 scan | grep "SSID")

  # Process the output of the iw command
  while IFS= read -r line; do
    # Extract the SSID name
    ssid=$(echo "$line" | awk -F': ' '{print $2}')

    # Get the current timestamp
    current_timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Check if the SSID has already been registered
    if [[ ! ${registered_ssids[$ssid]} ]]; then
      # Log the SSID with timestamp in the log file
      echo "SSID: $ssid - First seen: $current_timestamp" >> "$LOG_FILE"

      # Update the registered SSID with the current timestamp in the array
      registered_ssids[$ssid]="$current_timestamp"
    else
      # Get the previous timestamp for the registered SSID
      previous_timestamp=${registered_ssids[$ssid]}

      # Calculate the time duration between the previous and current timestamp
      time_duration=$(( $(date -d "$current_timestamp" +%s) - $(date -d "$previous_timestamp" +%s) ))

      # Update the timestamp for the registered SSID in the array
      registered_ssids[$ssid]="$current_timestamp"

      # Get the total time duration including the previous time durations
      total_duration=0
      if [[ ${registered_ssids["${ssid}_total_duration"]} ]]; then
        total_duration=${registered_ssids["${ssid}_total_duration"]}
      fi
      total_duration=$((total_duration + time_duration))
      registered_ssids["${ssid}_total_duration"]=$total_duration

      # Get the total time duration in hours, minutes, and seconds
      total_hours=$((total_duration / 3600))
      total_minutes=$(( (total_duration % 3600) / 60 ))
      total_seconds=$((total_duration % 60))

      # Get the current timestamp in date and time format
      current_timestamp_formatted=$(date "+%Y-%m-%d %H:%M:%S")

      # Update the log file with the updated timestamp and total time duration using sed
      sed -i "s/SSID: $ssid - Last seen: .*/SSID: $ssid - Last seen: $current_timestamp_formatted - Total time: $total_hours hours $total_minutes minutes $total_seconds seconds/" "$LOG_FILE"
      sed -i "s/SSID: $ssid - First seen: .*/SSID: $ssid - Last seen: $current_timestamp_formatted - Total time: $total_hours hours $total_minutes minutes $total_seconds seconds/" "$LOG_FILE"
    fi

    # Check if the log file still exists, recreate it if it's deleted
    if [[ ! -e "$LOG_FILE" ]]; then
      # Empty the registered SSIDs array
      registered_ssids=()
      # Recreate the log file
      create_log_file
    fi

  done <<< "$iw_output"

done
