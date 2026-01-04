#!/bin/bash
# validate-skill.sh - Validate a skill directory against the Agent Skills spec
# Usage: ./validate-skill.sh <skill-directory>
#
# Checks:
# - SKILL.md exists
# - Frontmatter has required name and description fields
# - Name matches directory name
# - Name follows naming rules (lowercase, hyphens only, no leading/trailing/consecutive hyphens)
# - Description is not empty and under 1024 chars

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

error() {
    echo -e "${RED}ERROR:${NC} $1"
    errors=$((errors + 1))
}

warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
    warnings=$((warnings + 1))
}

ok() {
    echo -e "${GREEN}OK:${NC} $1"
}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <skill-directory>"
    echo "Example: $0 .claude/skills/my-skill"
    exit 1
fi

SKILL_DIR="$1"
SKILL_FILE="$SKILL_DIR/SKILL.md"

echo "Validating skill: $SKILL_DIR"
echo "---"

# Check SKILL.md exists
if [[ ! -f "$SKILL_FILE" ]]; then
    error "SKILL.md not found in $SKILL_DIR"
    exit 1
fi
ok "SKILL.md exists"

# Extract frontmatter (only the first --- block at the start of the file)
# First check that file starts with ---
if ! head -1 "$SKILL_FILE" | grep -q '^---$'; then
    error "File must start with --- (YAML frontmatter)"
    exit 1
fi

# Extract content between first two --- lines
frontmatter=$(awk 'NR==1 && /^---$/ {start=1; next} start && /^---$/ {exit} start {print}' "$SKILL_FILE")

if [[ -z "$frontmatter" ]]; then
    error "No YAML frontmatter found (must start with ---)"
    exit 1
fi
ok "Frontmatter found"

# Extract name field (first occurrence only)
name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")

if [[ -z "$name" ]]; then
    error "Required field 'name' not found in frontmatter"
else
    ok "Name field present: $name"
    
    # Validate name format
    if [[ ! "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$name" =~ -- ]]; then
        error "Name '$name' is invalid. Must be lowercase alphanumeric with single hyphens, no leading/trailing hyphens"
    else
        ok "Name format valid"
    fi
    
    # Check name length
    if [[ ${#name} -gt 64 ]]; then
        error "Name exceeds 64 characters (${#name} chars)"
    fi
    
    # Check name matches directory
    dir_name=$(basename "$SKILL_DIR")
    if [[ "$name" != "$dir_name" ]]; then
        error "Name '$name' does not match directory name '$dir_name'"
    else
        ok "Name matches directory"
    fi
fi

# Extract description field
description=$(echo "$frontmatter" | grep -E '^description:' | sed 's/^description:[[:space:]]*//' | tr -d '"' | tr -d "'")

if [[ -z "$description" ]]; then
    error "Required field 'description' not found in frontmatter"
else
    ok "Description field present"
    
    # Check description length
    if [[ ${#description} -gt 1024 ]]; then
        error "Description exceeds 1024 characters (${#description} chars)"
    fi
    
    # Warn if description is too short
    if [[ ${#description} -lt 50 ]]; then
        warn "Description is very short (${#description} chars). Consider adding more detail about when to use this skill"
    fi
fi

# Count lines in SKILL.md
line_count=$(wc -l < "$SKILL_FILE" | tr -d ' ')
if [[ $line_count -gt 500 ]]; then
    warn "SKILL.md has $line_count lines. Consider moving content to references/ if > 500 lines"
else
    ok "SKILL.md is $line_count lines (under 500 recommended)"
fi

# Check for recommended sections
body=$(sed -n '/^---$/,/^---$/!p' "$SKILL_FILE" | tail -n +2)

has_when=$(echo "$body" | grep -qi "when to activate\|when to use" && echo "yes" || echo "no")
if [[ "$has_when" == "no" ]]; then
    warn "Missing 'When to activate' section"
fi

has_examples=$(echo "$body" | grep -qi "example\|## Example" && echo "yes" || echo "no")
if [[ "$has_examples" == "no" ]]; then
    warn "No examples found. Consider adding concrete examples"
fi

has_checklist=$(echo "$body" | grep -qi "checklist\|- \[ \]" && echo "yes" || echo "no")
if [[ "$has_checklist" == "no" ]]; then
    warn "No checklist found. Consider adding a definition of done"
fi

# Check optional directories
if [[ -d "$SKILL_DIR/scripts" ]]; then
    script_count=$(find "$SKILL_DIR/scripts" -type f | wc -l | tr -d ' ')
    ok "scripts/ directory found with $script_count file(s)"
fi

if [[ -d "$SKILL_DIR/references" ]]; then
    ref_count=$(find "$SKILL_DIR/references" -type f | wc -l | tr -d ' ')
    ok "references/ directory found with $ref_count file(s)"
fi

if [[ -d "$SKILL_DIR/assets" ]]; then
    asset_count=$(find "$SKILL_DIR/assets" -type f | wc -l | tr -d ' ')
    ok "assets/ directory found with $asset_count file(s)"
fi

# Summary
echo "---"
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}Validation failed:${NC} $errors error(s), $warnings warning(s)"
    exit 1
elif [[ $warnings -gt 0 ]]; then
    echo -e "${YELLOW}Validation passed with warnings:${NC} $warnings warning(s)"
    exit 0
else
    echo -e "${GREEN}Validation passed!${NC}"
    exit 0
fi
