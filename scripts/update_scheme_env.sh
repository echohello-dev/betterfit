#!/bin/bash
# Update Xcode scheme with environment variables from .env
# Usage: ./scripts/update_scheme_env.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$REPO_ROOT/.env"
SCHEME_FILE="$REPO_ROOT/Apps/iOS/BetterFit.xcodeproj/xcshareddata/xcschemes/BetterFit.xcscheme"

echo "🔧 Updating Xcode scheme with environment variables..."

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  .env file not found. Run: mise run supabase:env"
    exit 1
fi

# Load environment variables from .env
export $(cat "$ENV_FILE" | grep -v '^#' | xargs)

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
    echo "❌ Missing required environment variables in .env"
    echo "   Required: SUPABASE_URL, SUPABASE_ANON_KEY"
    exit 1
fi

# Check if scheme file exists
if [ ! -f "$SCHEME_FILE" ]; then
    echo "⚠️  Scheme file not found. Run: mise run ios:gen first"
    exit 1
fi

echo "✅ Found credentials in .env"
echo "   SUPABASE_URL: $SUPABASE_URL"
echo "   SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."

# Use Python to properly update XML (more reliable than sed for XML)
echo "📝 Injecting environment variables into scheme..."
python3 - "$SCHEME_FILE" "$SUPABASE_URL" "$SUPABASE_ANON_KEY" <<'EOF'
import xml.etree.ElementTree as ET
import sys

scheme_file = sys.argv[1]
supabase_url = sys.argv[2]
supabase_anon_key = sys.argv[3]

# Parse the scheme file
tree = ET.parse(scheme_file)
root = tree.getroot()

# Find or create EnvironmentVariables section in LaunchAction
for launch_action in root.findall('.//LaunchAction'):
    # Remove existing EnvironmentVariables if present
    for env_vars in launch_action.findall('EnvironmentVariables'):
        launch_action.remove(env_vars)
    
    # Create new EnvironmentVariables section
    env_vars = ET.SubElement(launch_action, 'EnvironmentVariables')
    
    # Add SUPABASE_URL
    env_var_url = ET.SubElement(env_vars, 'EnvironmentVariable')
    env_var_url.set('key', 'SUPABASE_URL')
    env_var_url.set('value', supabase_url)
    env_var_url.set('isEnabled', 'YES')
    
    # Add SUPABASE_ANON_KEY
    env_var_key = ET.SubElement(env_vars, 'EnvironmentVariable')
    env_var_key.set('key', 'SUPABASE_ANON_KEY')
    env_var_key.set('value', supabase_anon_key)
    env_var_key.set('isEnabled', 'YES')

# Write back to file with proper formatting
tree.write(scheme_file, encoding='UTF-8', xml_declaration=True)
print("✅ Updated scheme file")
EOF

echo "✨ Done! Environment variables have been injected into Xcode scheme"
echo "   Run the app in Xcode to use the updated credentials"
