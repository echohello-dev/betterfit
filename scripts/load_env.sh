#!/bin/bash
# Load .env file into build environment for Xcode
# This script reads the .env file and sets environment variables for the build

REPO_ROOT="${PROJECT_DIR}/../.."
ENV_FILE="$REPO_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
    # Source the .env file (safe parsing - only export key=value lines)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Export environment variable
        export "$key=$value"
    done < "$ENV_FILE"
fi
