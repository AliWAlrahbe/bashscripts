#!/usr/bin/env bash
set -uo pipefail

log_path=$1
declare -A keywords

#arguments validation
if (($# < 2)); then
    echo "Usage: $0 <log_file> <keyword1> <keyword1> and so on" >&2
    exit 1
fi

#add the arg2 arg3 and so on as keys to keywords associative array
for ((i=2; i<=$#; i++)); do
    keywords["${!i}"]=0
done

line_no=0
while IFS= read -r line; do
    ((line_no++))

    for keyword in "${!keywords[@]}"; do
        # lowercase conversion on both sides
        if [[ "${line,,}" == *"${keyword,,}"* ]]; then
            ((keywords["$keyword"]++))
            awk -v n="$line_no" '{print "line#", n, $1, $2, $3}' <<< "$line"
        fi
    done
done < "$log_path"

echo
echo "Results:"
for key in "${!keywords[@]}"; do
    echo "$key -> ${keywords[$key]}"
done
