#!/bin/bash

# Controlla se sono stati forniti l'IP e il path dei log
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <IP_address> <log_path>"
  exit 1
fi

IP_ADDRESS=$1
LOG_BASE_PATH=$2

# Definisce la sottodirectory per i log WHOIS
LOG_SUBDIR="whois"
LOG_PATH="${LOG_BASE_PATH}/${LOG_SUBDIR}"

# Crea la sottodirectory dei log se non esiste
mkdir -p "$LOG_PATH"

# Ottiene il timestamp corrente
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Definisce il nome del file di log nel nuovo percorso
LOG_FILE="${LOG_PATH}/${IP_ADDRESS}_whois_${TIMESTAMP}.log"

# Esegue il comando whois e salva l'output
whois "$IP_ADDRESS" > "$LOG_FILE"

echo "Risultato della ricerca WHOIS per $IP_ADDRESS salvato in $LOG_FILE"

