#!/bin/bash

# ==========================================================
# Impostazioni di configurazione
# ==========================================================

# URL del repository GitHub (valore predefinito)
DEFAULT_REPO_URL="git@github.com:StefanoRomanoA/get_attacker.git"

# Percorso locale del repository Git
LOCAL_REPO_PATH="$HOME/GIT/get_attacker"

# Percorso di installazione degli script a livello di sistema
INSTALL_PATH="/usr/local/bin/get_attacker"

# Percorso dei file di configurazione di Fail2ban nel repository
FAIL2BAN_REPO_CFG_PATH="$LOCAL_REPO_PATH/fail2ban_cfg"

# Percorsi di destinazione dei file di Fail2ban nel sistema
JAIL_DEST_PATH="/etc/fail2ban/jail.d/"
ACTION_DEST_PATH="/etc/fail2ban/action.d/"

# Percorso del file di log dell'installer
INSTALLER_LOG_DIR="./logs"
INSTALLER_LOG_FILE="${INSTALLER_LOG_DIR}/installer.log"

# ==========================================================
# Funzione di Logging
# ==========================================================

# Crea la directory dei log se non esiste
mkdir -p "$INSTALLER_LOG_DIR"

# Funzione per scrivere messaggi nel log con timestamp
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$INSTALLER_LOG_FILE"
}

# ==========================================================
# Controllo e Gestione Input e Modalità Test
# ==========================================================

TEST_MODE=false
REPO_URL=""

for arg in "$@"; do
    case "$arg" in
        -t|--test)
            TEST_MODE=true
            log_message "Modalità di test (--test) abilitata."
            shift
            ;;
        *)
            if [ -z "$REPO_URL" ]; then
                REPO_URL="$arg"
                shift
            else
                log_message "Errore: parametri non riconosciuti. Uso: $0 [-t|--test] [URL_repo]" >&2
                exit 1
            fi
            ;;
    esac
done

if [ -z "$REPO_URL" ]; then
    REPO_URL="$DEFAULT_REPO_URL"
    log_message "Usando l'URL del repository predefinito: $REPO_URL"
else
    log_message "Usando l'URL del repository fornito in input: $REPO_URL"
fi

if [ "$TEST_MODE" = true ]; then
    log_message "ATTENZIONE: ESECUZIONE IN MODALITÀ TEST. Nessuna operazione reale verrà eseguita."
fi

# ==========================================================
# Fase 1: Gestione del repository Git
# ==========================================================

log_message "==> Avvio del gestore di installazione..."
if [ ! -d "$LOCAL_REPO_PATH" ]; then
    log_message "Il repository Git non è stato trovato localmente. Eseguo la clonazione..."
    if [ "$TEST_MODE" = false ]; then
        mkdir -p "$(dirname "$LOCAL_REPO_PATH")"
        git clone "$REPO_URL" "$LOCAL_REPO_PATH"
        if [ $? -ne 0 ]; then
            log_message "Errore: la clonazione del repository è fallita." >&2
            exit 1
        fi
        log_message "Clonazione completata con successo."
    else
        log_message "[AZIONE TEST] Verrà eseguito: git clone \"$REPO_URL\" \"$LOCAL_REPO_PATH\""
    fi
fi

# Naviga nel repository locale
cd "$LOCAL_REPO_PATH" || { log_message "Errore: impossibile accedere alla directory locale."; exit 1; }

echo "Verifica la presenza di aggiornamenti remoti..."
git fetch

LOCAL_STATUS=$(git status)

if [[ "$LOCAL_STATUS" == *"Your branch is up to date"* ]]; then
    log_message "Nessun aggiornamento disponibile. Il repository è già sincronizzato."
    exit 0
fi

if [[ "$LOCAL_STATUS" != *"Your branch is ahead of"* ]]; then
    log_message "Il tuo branch locale non è in vantaggio. Prova a fare un 'git pull' manuale."
    git status
    exit 1
fi

# ==========================================================
# Fase 2: Installazione degli script
# ==========================================================

log_message "Sono presenti nuovi commit locali. Pronto per l'installazione."
read -p "Vuoi procedere con l'installazione in $INSTALL_PATH? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_message "Procedo con l'installazione..."
    
    if [ "$TEST_MODE" = false ]; then
        log_message "Pulizia della directory precedente degli script..."
        sudo rm -rf "$INSTALL_PATH"

        log_message "Copia dei nuovi script in $INSTALL_PATH..."
        sudo mkdir -p "$INSTALL_PATH"
        sudo cp *.sh "$INSTALL_PATH/"

        log_message "Configurazione dei permessi di esecuzione..."
        sudo chmod +x "$INSTALL_PATH"/*.sh
    else
        log_message "[AZIONE TEST] Verrà eseguito: sudo rm -rf \"$INSTALL_PATH\""
        log_message "[AZIONE TEST] Verrà eseguito: sudo mkdir -p \"$INSTALL_PATH\""
        log_message "[AZIONE TEST] Verrà eseguito: sudo cp *.sh \"$INSTALL_PATH/\""
        log_message "[AZIONE TEST] Verrà eseguito: sudo chmod +x \"$INSTALL_PATH\"/*.sh"
    fi

    if [ "$?" -ne 0 ] && [ "$TEST_MODE" = false ]; then
        log_message "Errore: l'installazione degli script non è riuscita." >&2
        exit 1
    fi
else
    log_message "Installazione degli script annullata dall'utente."
    exit 0
fi

# ==========================================================
# Fase 3: Gestione dei file di Fail2ban (Interattiva)
# ==========================================================
echo ""
read -p "Vuoi procedere con la configurazione di Fail2ban e il riavvio del servizio? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    log_message "Procedo con la configurazione di Fail2ban."

    log_message "Copia dei file di configurazione..."

    for file in "$FAIL2BAN_REPO_CFG_PATH/jail.d/"*.local; do
        filename=$(basename "$file")
        if [ "$TEST_MODE" = false ]; then
            if [ -f "${JAIL_DEST_PATH}$filename" ]; then
                log_message "Backup di $filename in ${JAIL_DEST_PATH}${filename}.bak-$TIMESTAMP"
                sudo cp "${JAIL_DEST_PATH}$filename" "${JAIL_DEST_PATH}${filename}.bak-$TIMESTAMP"
            fi
            sudo cp "$file" "${JAIL_DEST_PATH}"
        else
            log_message "[AZIONE TEST] Verrà eseguito: sudo cp \"$file\" \"$JAIL_DEST_PATH\""
            log_message "[AZIONE TEST] Backup di file esistente: ${JAIL_DEST_PATH}${filename}.bak-$TIMESTAMP"
        fi
    done

    for file in "$FAIL2BAN_REPO_CFG_PATH/action.d/"*.conf; do
        filename=$(basename "$file")
        if [ "$TEST_MODE" = false ]; then
            if [ -f "${ACTION_DEST_PATH}$filename" ]; then
                log_message "Backup di $filename in ${ACTION_DEST_PATH}${filename}.bak-$TIMESTAMP"
                sudo cp "${ACTION_DEST_PATH}$filename" "${ACTION_DEST_PATH}${filename}.bak-$TIMESTAMP"
            fi
            sudo cp "$file" "${ACTION_DEST_PATH}"
        else
            log_message "[AZIONE TEST] Verrà eseguito: sudo cp \"$file\" \"$ACTION_DEST_PATH\""
            log_message "[AZIONE TEST] Backup di file esistente: ${ACTION_DEST_PATH}${filename}.bak-$TIMESTAMP"
        fi
    done

    log_message "Riavvio del servizio Fail2ban per applicare le modifiche..."
    if [ "$TEST_MODE" = false ]; then
        sudo systemctl restart fail2ban
        if [ $? -eq 0 ]; then
            log_message "Installazione e configurazione completate con successo."
        else
            log_message "Errore: l'installazione o il riavvio di Fail2ban non sono riusciti." >&2
            exit 1
        fi
    else
        log_message "[AZIONE TEST] Verrà eseguito: sudo systemctl restart fail2ban"
        log_message "Simulazione completata con successo in modalità test."
    fi
else
    log_message "Configurazione di Fail2ban annullata dall'utente."
    log_message "Installazione degli script completata. Servizio Fail2ban non aggiornato."
    exit 0
fi

