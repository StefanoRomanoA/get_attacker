#!/bin/bash

# Controlla se sono stati forniti l'IP e la modalità
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <IP_address> <mode>"
  echo "Modalità ammesse: scan, whois, nmap"
  exit 1
fi

# Variabili per il percorso dei log
LOG_BASE_PATH="/var/log/get_attacker_logs"
MAIN_LOG_FILE="${LOG_BASE_PATH}/main.log"

# Crea la directory principale dei log se non esiste
mkdir -p "$LOG_BASE_PATH"

# Assegna gli argomenti a variabili per chiarezza
IP_ADDRESS=$1
MODE=$2

# Esegue l'azione in base alla modalità specificata
case "$MODE" in
  scan)
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Modalità 'scan' selezionata per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ./whois_lookup.sh "$IP_ADDRESS" "$LOG_BASE_PATH"
    ./nmap_scan.sh "$IP_ADDRESS" "$LOG_BASE_PATH"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Operazione di scansione completa per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ;;

  whois)
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Modalità 'whois' selezionata per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ./whois_lookup.sh "$IP_ADDRESS" "$LOG_BASE_PATH"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Ricerca WHOIS completa per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ;;

  nmap)
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Modalità 'nmap' selezionata per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ./nmap_scan.sh "$IP_ADDRESS" "$LOG_BASE_PATH"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Scansione NMAP completa per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    ;;

  *)
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Errore: Modalità non valida per IP $IP_ADDRESS" >> "$MAIN_LOG_FILE"
    echo "Errore: Modalità non valida. Le opzioni ammesse sono: scan, whois, nmap" >&2
    exit 1
    ;;
esac

exit 0

