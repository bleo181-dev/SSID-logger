#!/bin/bash

# Nome del file di log delle reti Wi-Fi
LOG_FILE="/home/pi/wifi_log.txt"

# Array per memorizzare gli SSID registrati
declare -A registered_ssids

# Verifica se il file di log esiste
if [[ -e "$LOG_FILE" ]]; then
  # Leggi il file di log e aggiungi gli SSID all'array dei SSID registrati
  while IFS= read -r line; do
    # Estra il nome dell'SSID dal file di log
    ssid=$(echo "$line" | awk -F': ' '{print $2}')
    
    # Aggiungi l'SSID all'array dei SSID registrati
    registered_ssids[$ssid]=1
  done < "$LOG_FILE"
fi

# Loop continuo per la registrazione delle reti Wi-Fi
while true; do
  # Rileva le reti Wi-Fi circostanti
  iw_output=$(sudo iw dev wlan0 scan | grep "SSID")
  
  # Elabora l'output del comando iw
  while IFS= read -r line; do
    # Estra il nome dell'SSID
    ssid=$(echo "$line" | awk -F': ' '{print $2}')
    
    # Verifica se l'SSID è già stato registrato
    if [[ ! ${registered_ssids[$ssid]} ]]; then
      # Registra l'SSID nel file di log
      echo "SSID: $ssid" >> $LOG_FILE
      
      # Aggiungi l'SSID all'array dei SSID registrati
      registered_ssids[$ssid]=1
    fi
  done <<< "$iw_output"
  
  # Aggiorna il file di log ogni 5 secondi (opzionale, puoi modificare l'intervallo di tempo secondo le tue preferenze)
  sleep 5
done
