# Docker Image Info Fetcher

A lightweight Bash utility that fetches metadata about a Docker image tag  
directly from the Docker Hub Registry API using `curl` and `jq`.

This tool is ideal for DevOps/Cloud engineers who want a quick way to inspect:
- Latest image tag  
- Last update timestamp  
- Architecture  
- Digest (immutable identifier)  
- Image size 

---

## 🔧 Features
- Uses `curl -sf` for safe API calls  
- Parses JSON using json processor `jq`  
- Includes ANSI color output  
- Supports custom API endpoints (default: official nginx image)  
- Converts image size to MB  

---

## 📦 Requirements
Ensure the following tools are installed:

```bash
bash
curl
jq
