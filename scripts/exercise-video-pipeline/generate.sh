#!/usr/bin/env bash
# generate.sh — exercise demo video pipeline.
#
# Stage 1 (anchors): fal.ai generates a start-pose image per exercise ×
#                    camera. Default model: fal-ai/recraft/v3 (photoreal,
#                    fast, great with branded equipment specs).
# Stage 2 (videos):  fal.ai animates one rep per exercise × camera.
#                    Default: xai/grok-imagine-video/reference-to-video,
#                    which takes a character reference image and a
#                    start-pose image and locks the man's look across the
#                    whole batch (~30s per video, file size ~0.9 MB).
#                    Override via FAL_VIDEO_ENDPOINT.
#
# To lock the bar/plate count even tighter across angles, switch to
# fal-ai/veo3.1/first-last-frame-to-video — uses first+last keyframes
# for stronger equipment/pose preservation. Slower (~2-3 min per video)
# and pricier, but the curl/bench/squat/curl outputs become near-perfect
# cross-angle matches.
#
# Why fal.ai for everything: single provider, same auth key (FAL_KEY),
# same upload pipeline, no cross-provider image model drift.
#
# Alternative image models on fal.ai (set FAL_IMAGE_ENDPOINT):
#   fal-ai/recraft/v3/text-to-image    — default, photoreal, great with text/brands
#   fal-ai/flux-2/flash                — fast, cheap
#   fal-ai/flux-pro/v1.1               — proven
#   fal-ai/ideogram/v3                 — strong composition
#
# Alternative video models (FAL_VIDEO_ENDPOINT):
#   xai/grok-imagine-video/reference-to-video  — default, fast + character ref
#   xai/grok-imagine-video/image-to-video      — image_url only, no char ref
#   fal-ai/veo3.1/first-last-frame-to-video   — tighter consistency, slower
#   fal-ai/veo3.1/fast/first-last-frame-to-video — Veo 3.1 fast
#   fal-ai/kling-video/v3/pro/image-to-video   — best quality, $$$, ~5min/clip
#   fal-ai/kling-video/v3/standard/image-to-video — good quality, $$ ~60s/clip
#   fal-ai/kling-video/v2.1/standard/image-to-video — older, cheaper, ~60s/clip
#   bytedance/seedance-2.0/image-to-video       — Seedance 2 standard
#   fal-ai/minimax/hailuo-02/standard/image-to-video — Hailuo 02 (same engine as mmx)

set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANCHORS_DIR="$SCRIPT_DIR/anchors"
VIDEOS_DIR="$SCRIPT_DIR/videos"

mkdir -p "$ANCHORS_DIR" "$VIDEOS_DIR"

# shellcheck source=prompts.sh
source "$SCRIPT_DIR/prompts.sh"
# shellcheck source=exercises.sh
source "$SCRIPT_DIR/exercises.sh"

CAMERAS=(front45 side45)
FAL_PYTHON=/Applications/Xcode.app/Contents/Developer/usr/bin/python3
FAL_IMAGE_ENDPOINT="${FAL_IMAGE_ENDPOINT:-fal-ai/flux-2/flash}"
FAL_VIDEO_ENDPOINT="${FAL_VIDEO_ENDPOINT:-xai/grok-imagine-video/reference-to-video}"
FAL_DURATION="${FAL_VIDEO_DURATION:-5}"
FAL_IMAGE_SIZE="${FAL_IMAGE_SIZE:-landscape_16_9}"

# ---------------------------------------------------------------------------
# Prompt builders
# ---------------------------------------------------------------------------

build_anchor_prompt () {
  local slug="$1" camera="$2" pose="$3"
  printf '%s %s %sThe subject is in this exact pose: %s Sharp photographic still, no motion, identical lighting, the barbell or trap bar must show the EXACT specified number of plates per side and the EXACT specified total weight, no text overlays, no text, letters, numbers, or labels on the plates or bar, no other people.\n' \
    "$CHARACTER_SCENE_BLOCK" "$(camera_block "$camera")" "$(equipment_block "$slug")" "$pose"
}

build_video_prompt () {
  local slug="$1" camera="$2" pose="$3" action="$4"
  printf '%s %s %sThe video begins and ends with the subject in this exact pose: %s Motion: %s Photorealistic motion blur only on the equipment during concentric and eccentric phases, sharp focus on the subject. No camera movement. Identical lighting and framing throughout. The barbell or trap bar must show the EXACT same load in every frame: the same number of plates per side, the same total weight, the same bar type — this is a critical consistency requirement. No text, letters, numbers, or labels on the plates or bar.\n' \
    "$CHARACTER_SCENE_BLOCK" "$(camera_block "$camera")" "$(equipment_block "$slug")" "$pose" "$action"
}

# Master character reference: same man, same studio, no equipment.
build_character_prompt () {
  local camera="$1" pose="$2"
  printf '%s %s The subject is in this exact pose: %s Sharp photographic still, no motion, identical lighting, no equipment, no text overlays, no other people.\n' \
    "$CHARACTER_SCENE_BLOCK" "$(camera_block "$camera")" "$pose"
}

# ---------------------------------------------------------------------------
# fal.ai image generation (shared by anchors + character refs)
# ---------------------------------------------------------------------------

generate_image_fal () {
  local out="$1" prompt="$2" prefix="$3"

  if [[ -z "${FAL_KEY:-}" ]]; then
    echo "    SKIP $out (FAL_KEY not set)" >&2
    return 0
  fi

  FAL_KEY="$FAL_KEY" FAL_IMAGE_ENDPOINT="$FAL_IMAGE_ENDPOINT" FAL_IMAGE_SIZE="$FAL_IMAGE_SIZE" \
    $FAL_PYTHON - "$out" "$prompt" "$prefix" <<'PY'
import os, sys, time
import fal_client

out, prompt, prefix = sys.argv[1:3+1]
endpoint = os.environ["FAL_IMAGE_ENDPOINT"]
size = os.environ.get("FAL_IMAGE_SIZE", "landscape_16_9")

# Schema varies by model. Recraft and similar accept a string enum like
# "landscape_16_9". Others accept width/height dicts. Pass a string here;
# it works for all the common fal.ai image models.
args = {"prompt": prompt, "image_size": size, "num_images": 1}

print(f"    submitting → {endpoint}", flush=True)
start = time.time()
result = fal_client.subscribe(endpoint, arguments=args)
elapsed = time.time() - start
print(f"    done in {elapsed:.1f}s", flush=True)

url = None
if isinstance(result, dict):
    if "images" in result and result["images"]:
        url = result["images"][0].get("url") or result["images"][0].get("image", {}).get("url")
    elif "image" in result:
        url = result["image"].get("url") if isinstance(result["image"], dict) else result["image"]
    elif "url" in result:
        url = result["url"]
if not url:
    raise SystemExit(f"could not extract image url from: {list(result.keys()) if isinstance(result, dict) else result}")

import urllib.request
urllib.request.urlretrieve(url, out)
print(f"    saved {out} ({os.path.getsize(out)} bytes)", flush=True)
PY
}

# Rename a recraft/fal output (which often lands as a numbered file) to
# the canonical name. fal returns the file at the requested out path
# directly, so this is a no-op safety net.
normalize_output () {
  local out="$1" prefix="$2"
  for f in "$ANCHORS_DIR"/${prefix}-*.*; do
    [[ -f "$f" ]] && mv "$f" "$out"
  done
}

# ---------------------------------------------------------------------------
# Stage 1 — anchors via fal.ai
# ---------------------------------------------------------------------------

for entry in "${EXERCISES[@]}"; do
  slug="$(slug_for "$entry")"
  pose="$(pose_for "$entry")"

  for camera in "${CAMERAS[@]}"; do
    anchor="$ANCHORS_DIR/${slug}__${camera}__anchor.jpg"

    if [[ -f "$anchor" ]]; then
      echo "    anchor exists: $anchor"
      continue
    fi

    echo "    generating anchor: $anchor"
    generate_image_fal "$anchor" "$(build_anchor_prompt "$slug" "$camera" "$pose")" "${slug}__${camera}__anchor"
  done
done

# ---------------------------------------------------------------------------
# Master character anchor
# ---------------------------------------------------------------------------

for camera in "${CAMERAS[@]}"; do
  char_ref="$ANCHORS_DIR/_character__${camera}.jpg"

  if [[ -f "$char_ref" ]]; then
    echo "    character ref exists: $char_ref"
    continue
  fi

  echo "    generating character ref: $char_ref"
  pose="standing relaxed in a neutral pose, arms at sides, feet hip-width apart, head facing the camera, neutral focused expression, no equipment"
  generate_image_fal "$char_ref" "$(build_character_prompt "$camera" "$pose")" "_character__${camera}"
done

# ---------------------------------------------------------------------------
# Stage 2 — videos via fal.ai
# ---------------------------------------------------------------------------

generate_video_fal () {
  local anchor="$1" video="$2" prompt="$3" char_ref="$4"

  if [[ -z "${FAL_KEY:-}" ]]; then
    echo "    SKIP $video (FAL_KEY not set)" >&2
    return 0
  fi

  FAL_KEY="$FAL_KEY" FAL_VIDEO_ENDPOINT="$FAL_VIDEO_ENDPOINT" FAL_DURATION="$FAL_DURATION" \
    $FAL_PYTHON - "$anchor" "$video" "$prompt" "$char_ref" <<'PY'
import os, sys, time, urllib.request
import fal_client

anchor, video, prompt, char_ref = sys.argv[1:5]
endpoint = os.environ["FAL_VIDEO_ENDPOINT"]
duration = os.environ["FAL_DURATION"]

print(f"    uploading start-pose anchor {anchor}", flush=True)
image_url = fal_client.upload_file(anchor)

# Schema per endpoint. Two flavors:
#   1) image-to-video / reference-to-video (Grok, Kling) — single first-frame + optional
#      character ref via `reference_image_urls` (an array).
#   2) first-last-frame-to-video (Veo 3.1) — explicit first_frame_url + last_frame_url.
#      Same image for both since the rep loops. Optional character ref via
#      `reference_images`. Duration must be "4s"/"6s"/"8s".
args = {"prompt": prompt, "duration": duration, "aspect_ratio": "16:9"}
if endpoint.endswith("reference-to-video"):
    args["image_url"] = image_url
    if char_ref:
        print(f"    uploading character ref {char_ref}", flush=True)
        char_url = fal_client.upload_file(char_ref)
        args["reference_image_urls"] = [char_url]
elif endpoint.endswith("first-last-frame-to-video"):
    args["first_frame_url"] = image_url
    args["last_frame_url"] = image_url
    if char_ref:
        print(f"    uploading character ref {char_ref}", flush=True)
        char_url = fal_client.upload_file(char_ref)
        args["reference_images"] = [char_url]
else:
    # Generic image-to-video.
    args["image_url"] = image_url

print(f"    submitting → {endpoint}", flush=True)
start = time.time()
result = fal_client.subscribe(endpoint, arguments=args)
elapsed = time.time() - start
print(f"    done in {elapsed:.1f}s", flush=True)

url = result["video"]["url"]
urllib.request.urlretrieve(url, video)
print(f"    saved {video} ({os.path.getsize(video)} bytes)", flush=True)
PY
}

for entry in "${EXERCISES[@]}"; do
  slug="$(slug_for "$entry")"
  pose="$(pose_for "$entry")"
  action="$(action_for "$entry")"

  for camera in "${CAMERAS[@]}"; do
    anchor="$ANCHORS_DIR/${slug}__${camera}__anchor.jpg"
    char_ref="$ANCHORS_DIR/_character__${camera}.jpg"
    video="$VIDEOS_DIR/${slug}__${camera}.mp4"

    if [[ -f "$video" ]]; then
      echo "    video exists: $video"
      continue
    fi

    prompt="$(build_video_prompt "$slug" "$camera" "$pose" "$action")"
    echo "    generating video: $video"
    generate_video_fal "$anchor" "$video" "$prompt" "$char_ref"
  done
done

echo "==> Done."
echo "    image model: $FAL_IMAGE_ENDPOINT"
echo "    video model: $FAL_VIDEO_ENDPOINT"
echo "    anchors: $ANCHORS_DIR"
echo "    videos:  $VIDEOS_DIR"