#!/bin/bash

# Name of the Wi-Fi networks log file
LOG_FILE="wifi_log.txt"

# Array to store registered SSIDs
declare -A registered_ssids

# Check if the log file exists
if [[ -e "$LOG_FILE" ]]; then
  # Read the log file and add SSIDs to the registered SSIDs array
  while IFS= read -r line; do
    # Extract the SSID name and timestamp from the log file
    ssid=$(echo "$line" | awk -F' |: ' '{print $2}')
    timestamp=$(echo "$line" | awk -F' |: ' '{print $3, $4}')
    
    # Add the SSID and timestamp to the registered SSIDs array
    registered_ssids[$ssid]="$timestamp"
  done < "$LOG_FILE"
fi

# Continuous loop for Wi-Fi network logging
while true; do
  # Detect surrounding Wi-Fi networks
  iw_output=$(sudo iw dev wlan0 scan | grep "SSID")
  
  # Process the output of the iw command
  while IFS= read -r line; do
    # Extract the SSID name
    ssid=$(echo "$line" | awk -F': ' '{print $2}')
    
    # Check if the SSID has already been registered
    if [[ ! ${registered_ssids[$ssid]} ]]; then
      # Get the current timestamp
      timestamp=$(date "+%Y-%m-%d %H:%M:%S")
      
      # Log the SSID with timestamp in the log file
      echo "SSID: $ssid - Timestamp: $timestamp" >> $LOG_FILE
      
      # Add the SSID and timestamp to the registered SSIDs array
      registered_ssids[$ssid]="$timestamp"
    fi
  done <<< "$iw_output"
  
  # Update the log file every 5 seconds (optional, you can modify the time interval according to your preference)
  sleep 5
done
