#!/usr/bin/env bash
set -euo pipefail

# This script monitors CPU, RAM, and disk usage.
# If usage exceeds the desired limits, the sysadmin will get an email to take action.

LOG_FILE=${1:-"/var/log/monitor_resources.log"}

echo "===== $(date) =====" | tee -a "$LOG_FILE"

############################################
# CPU USAGE
############################################
CPU_THRESHOLD=80

IDLE=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | awk '{print $1}')
CPU_USAGE_RAW=$(bc <<< "100 - $IDLE")
CPU_USAGE=${CPU_USAGE_RAW%.*}

echo "[INFO] CPU usage: $CPU_USAGE %" | tee -a "$LOG_FILE"


############################################
# MEMORY USAGE
############################################
MEM_THRESHOLD=80

USED_MEM=$(free -m | awk '/^Mem:/ {print $3}')
TOTAL_MEM=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USAGE_RAW=$(bc <<< "scale=1; ($USED_MEM/$TOTAL_MEM)*100")
MEM_USAGE=${MEM_USAGE_RAW%.*}

echo "[INFO] Memory usage: $MEM_USAGE %" | tee -a "$LOG_FILE"


############################################
# DISK USAGE
############################################
DISK_THRESHOLD=80
DISK_ALERT=0         # FLAG

echo "[INFO] Disk usage for /dev devices:" | tee -a "$LOG_FILE"

while read -r FS BLOCKS USED AVAIL PERCENT MOUNT; do
    DISK_USAGE=${PERCENT%\%}

    if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
        STATUS="⚠️ WARNING"
        DISK_ALERT=1
    else
        STATUS="OK"
    fi

    echo "  - $MOUNT ($FS): ${DISK_USAGE}% [$STATUS]" | tee -a "$LOG_FILE"

done < <(df -P | grep "^/dev")


############################################
# SEND EMAIL IF ANY ALERT
############################################
if [[ "$CPU_USAGE" -ge "$CPU_THRESHOLD" || "$MEM_USAGE" -ge "$MEM_THRESHOLD" || "$DISK_ALERT" -eq 1 ]]; then

    JSON_BODY=$(cat <<EOF
{
  "FromEmail":"alert@corefortify.com",
  "FromName":"Core Fortify ALERT",
  "Recipients":[
    {
      "Email":"ali.rahabi@gmail.com",
      "Name":"Ali"
    }
  ],
  "Subject":"Server Alert ⚠️",
  "Html-part":"<h3>Server Alert from $(hostname)</h3><p><b>CPU usage:</b> ${CPU_USAGE}% (limit: ${CPU_THRESHOLD}%)<br/><b>Memory usage:</b> ${MEM_USAGE}% (limit: ${MEM_THRESHOLD}%)<br/><b>Disk alert:</b> ${DISK_ALERT}<br/><b>Check logs at:</b> ${LOG_FILE}</p>"
}
EOF
    )

    curl -s --fail \
      -X POST \
      --user "$MAILJET_API_KEY:$MAILJET_API_SECRET" \
      https://api.mailjet.com/v3/send \
      -H 'Content-Type: application/json' \
      -d "$JSON_BODY"

fi
