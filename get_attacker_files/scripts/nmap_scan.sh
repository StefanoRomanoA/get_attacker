#!/bin/bash

# Controlla se sono stati forniti l'IP e il path dei log
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <IP_address> <log_path>"
  exit 1
fi

IP_ADDRESS=$1
LOG_BASE_PATH=$2

# Definisce la sottodirectory per i log NMAP
LOG_SUBDIR="nmap"
LOG_PATH="${LOG_BASE_PATH}/${LOG_SUBDIR}"

# Crea la sottodirectory dei log se non esiste
mkdir -p "$LOG_PATH"

# Ottiene il timestamp corrente
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Definisce il nome del file di log nel nuovo percorso
LOG_FILE="${LOG_PATH}/${IP_ADDRESS}_nmap_${TIMESTAMP}.log"

# Esegue la scansione Nmap e salva l'output
nmap -sV -p- -oN "$LOG_FILE" "$IP_ADDRESS"

echo "Risultato della scansione Nmap per $IP_ADDRESS salvato in $LOG_FILE"

