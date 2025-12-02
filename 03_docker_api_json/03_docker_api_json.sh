#!/usr/bin/env bash
set -euo pipefail

# ANSI color codes
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Read the API endpoint from the user or use the default one.
DEFAULT_ENDPOINT="https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=1"

read -r -p "Enter image API endpoint (leave empty for default nginx): " API_ENDPOINT
API_ENDPOINT=${API_ENDPOINT:-$DEFAULT_ENDPOINT}

echo -e "${BLUE}Using endpoint:${RESET} $API_ENDPOINT"

JSON_RESPONSE=$(curl -sf "$API_ENDPOINT") || {
  echo -e "${RED}Failed to fetch data from $API_ENDPOINT${RESET}"
  exit 1
}

TAG=$(printf '%s' "$JSON_RESPONSE" | jq -r '.results[0].name')
LAST_UPDATE=$(printf '%s' "$JSON_RESPONSE" | jq -r '.results[0].last_updated')
ARCH=$(printf '%s' "$JSON_RESPONSE" | jq -r '.results[0].images[0].architecture')
DIGEST=$(printf '%s' "$JSON_RESPONSE" | jq -r '.results[0].images[0].digest')
FULL_SIZE=$(printf '%s' "$JSON_RESPONSE" | jq -r '.results[0].full_size')
FULL_SIZE_MB=$(( FULL_SIZE / 1024 / 1024 ))


echo -e "${BLUE}############################################${RESET}"
echo -e "${GREEN}# Image details${RESET}"
echo -e "${BLUE}############################################${RESET}"

echo -e "${YELLOW}[INFO]${RESET} Tag: ${GREEN}${TAG}${RESET}"
echo -e "${YELLOW}[INFO]${RESET} Last Update: ${GREEN}${LAST_UPDATE}${RESET}"
echo -e "${YELLOW}[INFO]${RESET} Architecture: ${GREEN}${ARCH}${RESET}"
echo -e "${YELLOW}[INFO]${RESET} Digest: ${GREEN}${DIGEST}${RESET}"
echo -e "${YELLOW}[INFO]${RESET} Full size in MB: ${GREEN}${FULL_SIZE_MB}${RESET}"
