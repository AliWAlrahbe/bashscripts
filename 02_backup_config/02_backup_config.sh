#!/usr/bin/env bash
set -euo pipefail

log () {
    local level="$1"
    shift
    local message="$*"
    ts=$(date +"%Y-%m-%d_%H-%M-%S")
    echo "[$level] $message - $ts" | tee -a "$LOG_FILE"
}

#Read the source and the disctination
SOURCE_FILE=${1:-"/etc/nginx/nginx.conf"}
BACKUP_DIR=${2:-"/var/backups"}
LOG_FILE=${3:-"/var/log/backup_config.log"}
mkdir -p "$(dirname "$LOG_FILE")"

if [[ ! -f "$SOURCE_FILE" ]]; then
    log "⛔️ ERROR" "The source file does not exist, please double check"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BASENAME=$(basename "$SOURCE_FILE")
BACKUP_FILE="$BACKUP_DIR/$BASENAME.$TIMESTAMP.bak"

log "🔔 INFO" "Backing up $SOURCE_FILE to $BACKUP_FILE" 
cp "$SOURCE_FILE" "$BACKUP_FILE"
log "✅ OK" "Backup completed successfully!"
