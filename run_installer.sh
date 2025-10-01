#!/bin/bash

PLAYBOOK="get_attacker_ansible/install.yml"
HOST_TARGET=""
ANSIBLE_FLAGS=""
DRY_RUN_FLAGS=""
TARGET_HOST_FLAG=""

# --- Funzione di help ---
usage() {
  echo "Uso: $0 [-t] [-b] [-s] -h <host_target> | <host_target>"
  echo ""
  echo "Opzioni:"
  echo "  -t : Modalità Dry-Run (simulazione) (--check --diff)."
  echo "  -b : Chiedi la password per l'elevazione privilegi (sudo) (-K)."
  echo "  -s : Chiedi la password/passphrase SSH (-k). Usare ssh-agent è raccomandato."
  echo "  -h : Specifica l'host di destinazione."
  echo ""
  echo "Esempio con tutte le opzioni: $0 -t -b -s -h server_remoto_01"
  echo "Esempio minimo: $0 localhost"
  exit 1
}

# --- Parsing degli argomenti ---
while getopts "tbsh:" opt; do
  case $opt in
    t)
      DRY_RUN_FLAGS="--check --diff"
      echo "Modalità Dry-Run abilitata."
      ;;
    b)
      ANSIBLE_FLAGS="${ANSIBLE_FLAGS} -K"
      echo "Richiesta password Sudo abilitata."
      ;;
    s)
      ANSIBLE_FLAGS="${ANSIBLE_FLAGS} -k"
      echo "Richiesta password/passphrase SSH abilitata."
      ;;
    h)
      HOST_TARGET="$OPTARG"
      ;;
    \?)
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Se l'host non è stato specificato con -h, usa l'argomento posizionale
if [ -z "$HOST_TARGET" ] && [ -n "$1" ]; then
    HOST_TARGET="$1"
fi

if [ -z "$HOST_TARGET" ]; then
    echo "Errore: specificare l'host di destinazione." >&2
    usage
fi

# Costruisci il flag finale per l'host
TARGET_HOST_FLAG="-l ${HOST_TARGET}"

echo "--------------------------------------------------------"
echo "Avvio playbook su host: ${HOST_TARGET}"
echo "Opzioni Ansible: ${ANSIBLE_FLAGS} ${DRY_RUN_FLAGS} -l ${HOST_TARGET}"
echo "--------------------------------------------------------"

# Esecuzione del comando Ansible. Aggiungiamo --ask-vault-pass di default, essendo una best practice.
ansible-playbook ${PLAYBOOK} --ask-vault-pass ${ANSIBLE_FLAGS} ${DRY_RUN_FLAGS} ${TARGET_HOST_FLAG}

