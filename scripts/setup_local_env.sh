#!/bin/bash
# Setup local .env file with Supabase credentials
# Usage: ./scripts/setup_local_env.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$REPO_ROOT/.env"
ENV_EXAMPLE="$REPO_ROOT/.env.example"

echo "🔧 Setting up local .env with Supabase credentials..."

# Create .env from template if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo "📝 Creating .env from template..."
    cp "$ENV_EXAMPLE" "$ENV_FILE"
fi

# Get Supabase status
echo "🔍 Fetching Supabase credentials..."
STATUS_OUTPUT=$(cd "$REPO_ROOT" && supabase status 2>/dev/null || echo "")

if [ -z "$STATUS_OUTPUT" ]; then
    echo "⚠️  Supabase is not running. Run: mise run supabase:start"
    exit 1
fi

# Extract credentials - look for the keys after the label
ANON_KEY=$(echo "$STATUS_OUTPUT" | grep -E "Publishable|anon" | grep -oE "sb_publishable_[A-Za-z0-9_]+" | head -1)
SERVICE_KEY=$(echo "$STATUS_OUTPUT" | grep -E "Secret|secret" | grep -oE "sb_secret_[A-Za-z0-9_]+" | head -1)

if [ -z "$ANON_KEY" ]; then
    echo "❌ Failed to extract SUPABASE_ANON_KEY from supabase status"
    exit 1
fi

echo "✅ Found credentials"
echo "   Anon Key: ${ANON_KEY:0:20}..."
echo "   Service Key: ${SERVICE_KEY:0:20}..."

# Update .env file
echo "📝 Updating .env..."

# Use sed to update values (with proper escaping)
sed -i '' "s|^SUPABASE_URL=.*|SUPABASE_URL=http://127.0.0.1:54321|" "$ENV_FILE"
sed -i '' "s|^SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$ANON_KEY|" "$ENV_FILE"

# Add SUPABASE_SECRET_KEY if it doesn't exist
if ! grep -q "^SUPABASE_SECRET_KEY=" "$ENV_FILE"; then
    echo "SUPABASE_SECRET_KEY=$SERVICE_KEY" >> "$ENV_FILE"
else
    sed -i '' "s|^SUPABASE_SECRET_KEY=.*|SUPABASE_SECRET_KEY=$SERVICE_KEY|" "$ENV_FILE"
fi

echo "✨ Done! Updated .env with:"
echo "   SUPABASE_URL=http://127.0.0.1:54321"
echo "   SUPABASE_ANON_KEY=${ANON_KEY:0:20}..."
echo "   SUPABASE_SECRET_KEY=${SERVICE_KEY:0:20}..."
