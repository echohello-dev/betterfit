#!/bin/bash
# new-skill.sh - Create a new skill from template
# Usage: ./new-skill.sh <skill-name> [description] [skills-directory]
#
# Creates a new skill directory with SKILL.md template following the Agent Skills spec.
# The skills directory can be customized via the third argument or SKILLS_DIR env var.

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <skill-name> [description] [skills-directory]"
    echo ""
    echo "Arguments:"
    echo "  skill-name        Required. Lowercase alphanumeric with hyphens (e.g., code-review)"
    echo "  description       Optional. What the skill does and when to use it"
    echo "  skills-directory  Optional. Where to create the skill (default: \$SKILLS_DIR or .claude/skills)"
    echo ""
    echo "Examples:"
    echo "  $0 code-review 'Review code for best practices'"
    echo "  $0 my-skill 'Description' ./skills"
    echo "  SKILLS_DIR=.cursor/skills $0 my-skill 'Description'"
    exit 1
fi

SKILL_NAME="$1"
DESCRIPTION="${2:-TODO: Add a description of what this skill does and when to use it.}"
# Allow override via argument, then env var, then default
SKILLS_DIR="${3:-${SKILLS_DIR:-.claude/skills}}"

# Validate name format
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || [[ "$SKILL_NAME" =~ -- ]]; then
    echo "ERROR: Invalid skill name '$SKILL_NAME'"
    echo "Name must be lowercase alphanumeric with single hyphens, no leading/trailing hyphens"
    exit 1
fi

if [[ ${#SKILL_NAME} -gt 64 ]]; then
    echo "ERROR: Skill name exceeds 64 characters"
    exit 1
fi

# Determine skills directory
SKILLS_DIR=".claude/skills"
if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "Creating skills directory: $SKILLS_DIR"
    mkdir -p "$SKILLS_DIR"
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [[ -d "$SKILL_DIR" ]]; then
    echo "ERROR: Skill directory already exists: $SKILL_DIR"
    exit 1
fi

echo "Creating skill: $SKILL_NAME"
mkdir -p "$SKILL_DIR"

# Create SKILL.md from template
cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $DESCRIPTION
---

# ${SKILL_NAME//-/ } Skill

Use this skill when [describe specific trigger conditions].

## When to activate this skill

- User asks to [trigger 1]
- User wants to [trigger 2]
- User needs help with [trigger 3]

## Instructions

### Step 1: [First step]

[Describe what to do]

### Step 2: [Second step]

[Describe what to do]

### Step 3: [Third step]

[Describe what to do]

## Examples

### Example: [Scenario name]

**Input**: [Describe the input or user request]

**Output**: [Describe the expected result]

\`\`\`
# Example code or output
\`\`\`

## Edge cases

- **[Edge case 1]**: [How to handle it]
- **[Edge case 2]**: [How to handle it]

## Checklist

Before finishing:

- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]
EOF

echo "Created: $SKILL_DIR/SKILL.md"

# Ask about optional directories
echo ""
echo "Optional directories (create manually if needed):"
echo "  mkdir -p $SKILL_DIR/scripts    # Executable code"
echo "  mkdir -p $SKILL_DIR/references # Additional documentation"
echo "  mkdir -p $SKILL_DIR/assets     # Templates, schemas, images"
echo ""
echo "Done! Edit $SKILL_DIR/SKILL.md to customize your skill."

# Get the directory where this script lives to suggest validation command
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Validate with: $SCRIPT_DIR/validate-skill.sh $SKILL_DIR"
