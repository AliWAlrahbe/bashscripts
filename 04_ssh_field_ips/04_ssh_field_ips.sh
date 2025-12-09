#!/usr/bin/env bash
set -euo pipefail

MIN_FAILS=${1:-3}   #default 3 attempts

#detecting OS and auth log file
detect_auth_log() {
    local os_family=""
    local auth_log=""

    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        os_family="${ID_LIKE:-$ID}"

        case "$os_family" in
            *debian*|*ubuntu*)
                auth_log="/var/log/auth.log"
                os_family="debian family"
                ;;
            *)
                auth_log="/var/log/secure"
                os_family="rhel family"
                ;;
        esac
    else
        # Fallback for /etc/os-release
        if [[ -f /var/log/auth.log ]]; then
            auth_log="/var/log/auth.log"
        else
            auth_log="/var/log/secure"
        fi
        os_family="unknown family"
    fi

    #on stderr
    echo "[INFO] Detected OS family: $os_family" >&2
    echo "[INFO] Using auth log: $auth_log" >&2

    #on stdout
    printf '%s\n' "$auth_log"
}

AUTH_LOG=$(detect_auth_log)

#check if the log file is accessible and readable  
if [[ ! -r "$AUTH_LOG" ]]; then
    echo "[ERROR] Auth log file '$AUTH_LOG' is not readable or does not exist." >&2
    exit 1
fi

awk -v min="$MIN_FAILS" '/Failed password/ {
    ip = $(NF-3)
    count[ip]++
} END {
    for (ip in count) {
        if (count[ip] >= min) {
            printf "%-16s %d\n", ip, count[ip]
        }
    }
}' "$AUTH_LOG" | sort -k2 -nr
