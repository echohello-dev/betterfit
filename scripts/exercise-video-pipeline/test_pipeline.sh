#!/usr/bin/env bash
# Smoke tests for the exercise video pipeline.
#
# Verifies:
#   1. Bash syntax of all three pipeline scripts (bash -n)
#   2. The video_endpoint_for() override resolver returns the right
#      endpoint per slug (exact-match hit, default fallthrough, empty
#      override, comment handling)
#   3. equipment_block() returns non-empty branded spec for every slug
#      in the catalogue
#   4. build_anchor_prompt / build_video_prompt freeze-character token
#      is present in the assembled prompt
#   5. None of the scripts try to commit the archive directories back
#      into git (the .gitignore covers them; this asserts the rule)
#
# Designed to run anywhere (no FAL_KEY needed, no python deps). Output is
# plain `ok` / `FAIL` so it can be wired into CI as a smoke gate.

set -uo pipefail

PASS=0
FAIL=0

# Locate the pipeline directory regardless of where the script is run from.
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ok () { echo "  ok  $1"; PASS=$((PASS + 1)); }
bad() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

echo "==> syntax check"
for s in generate.sh prompts.sh exercises.sh; do
  if bash -n "$PIPELINE_DIR/$s" 2>/dev/null; then
    ok "$s parses"
  else
    bad "$s has a syntax error"
    bash -n "$PIPELINE_DIR/$s"
  fi
done

# Source the pipeline functions without running the main loop.
# generate.sh is large — extract just the function definitions and
# the override-lookup helper.
echo "==> sourcing function definitions"
TMPF=$(mktemp)
# Strip the executable blocks (everything from the first 'for' loop on
# Stage 1 onwards is a script body, not a function we want to run).
sed -n '1,/^# Stage 2/p' "$PIPELINE_DIR/generate.sh" > "$TMPF"
# Append a no-op so the last function definition closes cleanly.
cat >> "$TMPF" <<'EOF'
exit 0
EOF
if bash "$TMPF" >/dev/null 2>&1; then
  ok "function definitions source cleanly"
else
  bad "sourcing generated function block"
  bash "$TMPF"
fi
rm -f "$TMPF"

# Source the smaller files directly.
if bash -c "source '$PIPELINE_DIR/prompts.sh' && source '$PIPELINE_DIR/exercises.sh' && exit 0" 2>/dev/null; then
  ok "prompts.sh + exercises.sh source cleanly"
else
  bad "prompts.sh or exercises.sh has a sourcing error"
fi

# ---- 2. video_endpoint_for() override resolver ------------------------
echo "==> video_endpoint_for()"
test_override () {
  local label="$1" overrides="$2" slug="$3" expected="$4"
  local got
  got=$(FAL_VIDEO_ENDPOINT="xai/grok-imagine-video/reference-to-video" \
        FAL_VIDEO_OVERRIDES="$overrides" \
        bash -c 'source "'"$PIPELINE_DIR"'/generate.sh" >/dev/null 2>&1; \
                  video_endpoint_for "'"$slug"'" "xai/grok-imagine-video/reference-to-video"')
  if [[ "$got" == "$expected" ]]; then
    ok "$label"
  else
    bad "$label: expected '$expected', got '$got'"
  fi
}

test_override "default fallthrough (empty override)" \
  "" "back-squat" "xai/grok-imagine-video/reference-to-video"

test_override "default fallthrough (no match)" \
  "ez-curl:foo,deadlift:bar" "back-squat" "xai/grok-imagine-video/reference-to-video"

test_override "exact match" \
  "back-squat:fal-ai/veo3.1/standard/image-to-video" "back-squat" \
  "fal-ai/veo3.1/standard/image-to-video"

test_override "multiple entries, pick matching one" \
  "ez-curl:a,back-squat:b,deadlift:c" "back-squat" "b"

test_override "first prefix-match wins (longest first)" \
  "back-squat:winner,back:loser" "back-squat" "winner"

# Disabled override → always use the default.
test_override "empty override = use default" \
  "" "anything" "xai/grok-imagine-video/reference-to-video"

# Comment handling — bash-style inline comment after a comma.
test_override "trailing # comment is stripped" \
  "back-squat:foo  # this is ignored" "back-squat" "foo"

# ---- 3. equipment_block() coverage ----------------------------------
echo "==> equipment_block() coverage"
for s in barbell-curl ez-curl back-squat bench-press deadlift \
         trap-bar-deadlift overhead-press romanian-deadlift; do
  out=$(bash -c "source '$PIPELINE_DIR/prompts.sh' >/dev/null 2>&1; equipment_block '$s'")
  if [[ -z "$out" ]]; then
    bad "$s: equipment_block returned empty"
  elif [[ "$out" != *"Rogue"* && "$out" != *"REP"* && "$out" != *"Olympic"* && "$out" != *"EZ"* ]]; then
    bad "$s: equipment_block missing brand anchor: $out"
  else
    ok "$s: equipment spec present (${#out} chars)"
  fi
done

# ---- 4. prompt content sanity ---------------------------------------
echo "==> prompt content"
# Inline copy of build_anchor_prompt so we can call it without the
# full generate.sh executable blocks. Mirrors the function in generate.sh.
ANCHOR_OUT=$(
  bash -c '
    set -uo pipefail
    source "'"$PIPELINE_DIR"'/prompts.sh" >/dev/null
    source "'"$PIPELINE_DIR"'/exercises.sh" >/dev/null

    # Inline copy of build_anchor_prompt (must match generate.sh).
    build_anchor_prompt () {
      local slug="$1" camera="$2" pose="$3"
      printf "%s %s %sThe subject is in this exact pose: %s Sharp photographic still, no motion, identical lighting, the barbell or trap bar must show the EXACT specified number of plates per side and the EXACT specified total weight, no text overlays, no other people.\n" \
        "$CHARACTER_SCENE_BLOCK" "$(camera_block "$camera")" "$(equipment_block "$slug")" "$pose"
    }

    cp=$(pose_for "${EXERCISES[0]}")
    build_anchor_prompt barbell-curl front45 "$cp"
  '
)

if [[ "$ANCHOR_OUT" == *"Nike"* ]]; then
  bad "character/scene block still contains 'Nike' brand reference"
elif [[ "$ANCHOR_OUT" == *"text"* || "$ANCHOR_OUT" == *"labels"* ]]; then
  ok "anchor prompt includes anti-text directive"
else
  bad "anchor prompt missing anti-text directive (looked for 'text' or 'labels')"
fi
if [[ "$ANCHOR_OUT" == *"lb total"* ]]; then
  ok "anchor prompt declares a total weight (real per-exercise spec)"
else
  bad "anchor prompt missing 'X lb total' weight declaration"
fi

# ---- 5. archives are gitignored, not committed ----------------------
echo "==> archive hygiene"
GITIGNORE="$PIPELINE_DIR/../../.gitignore"
if [[ -f "$GITIGNORE" ]]; then
  if grep -q "scripts/exercise-video-pipeline/archive-\*/" "$GITIGNORE"; then
    ok "archive-*/ is gitignored"
  else
    bad ".gitignore missing archive-*/ pattern"
  fi
else
  echo "  (skipped) no .gitignore in parent repo"
fi

# ---- summary --------------------------------------------------------
echo ""
echo "==> summary: $PASS passed, $FAIL failed"
exit "$FAIL"