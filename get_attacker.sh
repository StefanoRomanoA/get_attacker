#!/bin/bash
# Get the data about the ssh attacker and possibly adopt countermesure
#
# $1 = ip
# $2 = mode: whois; scan
# logs: whois_IP_timestamp.log; nmap_IP_timestamp.log

TS=date +"%Y%m%d_%H%M%S"
LOG_PATH=/opt/get_attacker_logs/
WHOIS_LOG=whois_$1_$TS.log
NMAP_LOG=nmap_$1_$TS.log


