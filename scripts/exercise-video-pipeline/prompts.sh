#!/usr/bin/env bash
# prompts.sh — shared prompt fragments for the BetterFit demo pipeline.
#
# Three reusable fragments combine into every generation:
#   CHARACTER_SCENE_BLOCK  — the man + outfit + studio. Frozen, byte-identical
#                             across every call so the look stays consistent.
#   camera_block ANGLE      — front45 | side45. Frozen per angle.
#   equipment_block SLUG    — per-exercise gear: real brands/models, real
#                             dimensions, exact plate count, exact weight.
#                             Same string is injected into both anchor and
#                             video prompts for both angles of an exercise
#                             so the load stays consistent across views.

set -euo pipefail

# Generic visual baseline for the man + studio. The outfit + studio are
# frozen so the character reads the same in every clip; equipment details
# live in equipment_block below.
CHARACTER_SCENE_BLOCK='Cinematic ultra-realistic 4K film still. Same athletic-fit man, mid-30s, short dark hair, neutral focused expression, wearing a fitted black short-sleeve performance athletic shirt, black athletic shorts, and black training shoes. Black horse stall mat rubber flooring, bare concrete-block-wall home gym studio, soft even overhead lighting. Subject sharp with shallow depth of field, photorealistic, anamorphic widescreen, no text overlays, no other people, no visible wall signage, rack, or cable machine.'

camera_block () {
  case "$1" in
    front45)
      echo 'Camera: 45-degree front angle, slightly off-center to the subject'\''s left, full body visible from head to shoes, arms and equipment clearly framed.'
      ;;
    side45)
      echo 'Camera: 45-degree side angle showing the subject'\''s right profile, full body visible from head to shoes, arms and equipment clearly framed, subtle horizon line on the wall behind.'
      ;;
    *)
      echo "Unknown camera angle: $1" >&2
      return 1
      ;;
  esac
}

# ----------------------------------------------------------------------------
# Per-exercise equipment specs.
#
# Each spec is the EXACT same string used for both anchor and video prompts
# across both camera angles of an exercise. Includes:
#   - Real brand + model
#   - Real physical dimensions (length, diameter, height)
#   - Exact plate count per side, per weight
#   - Total weight (helps the model stay consistent)
#
# If you add a new exercise, add a matching case here AND a matching entry
# in exercises.sh. Both files use the same slug.
#
# Plate key (so the counts are explicit and unambiguous):
#   "two 45 lb plates per side"     = 2 × 20 kg black rubber bumper
#   "three 45 lb plates per side"   = 3 × 20 kg black rubber bumper
#   "one 45 lb plate per side"      = 1 × 20 kg black rubber bumper
#   "no plates"                     = empty bar (warm-up / technique work)
# ----------------------------------------------------------------------------

equipment_block () {
  local slug="$1"
  case "$slug" in
    barbell-curl)
      # 180 lb — moderate, classic iron. Four 45s on the bar = 17.5" iron at 1.3" thick.
      echo "Equipment: Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m shaft, 28 mm grip diameter, 50 mm rotating sleeves), loaded with two 45 lb cast iron Olympic plates on each side (445 mm / 17.5 in diameter, 33 mm / 1.3 in thick, painted matte black), 180 lb total." ;;
    ez-curl)
      # 90 lb — light, single 45 per side on the EZ bar.
      echo "Equipment: Rogue ZEUS Olympic EZ Curl Bar — a W-shaped zig-zag curl bar with two distinct angled bends that offset the wrists, knurled stainless steel, 1.2 m shaft, NOT a straight barbell — the bar must visibly curve upward at the grip zones, loaded with one 45 lb cast iron Olympic plate on each side (445 mm / 17.5 in diameter, 33 mm / 1.3 in thick, painted matte black), 90 lb total." ;;
    back-squat)
      # 315 lb — heavy, bumpers. Three 45s on the bar = 17.7" bumpers at 2.9" thick.
      echo "Equipment: Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m, 28 mm grip, 50 mm sleeves), loaded with three 45 lb black rubber bumper plates on each side (450 mm / 17.7 in diameter, 74 mm / 2.9 in thick), 270 lb total, bar racked across the upper trapezius behind the neck." ;;
    bench-press)
      # 225 lb — moderate, iron. Four plates on the bar = 2x 45 + 1x 25 + 1x 10 per side.
      echo "Equipment: Rogue Monster Lite flat bench (1.4 m long, 60 cm wide back pad) AND Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m, 28 mm grip), loaded with one 45 lb cast iron plate, one 25 lb cast iron plate, and one 10 lb cast iron plate on each side (the 45s are 17.5 in diameter, the 25s are 11 in diameter, the 10s are 9 in diameter — visible diameter change as you go outward from the center, exactly how real iron plates are loaded), 160 lb total of cast iron." ;;
    deadlift)
      # 405 lb — heavy, bumpers. Four 45s = 8" of plate per side.
      echo "Equipment: Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m, 28 mm grip, 50 mm sleeves), loaded with four 45 lb black rubber bumper plates on each side (450 mm / 17.7 in diameter, 74 mm / 2.9 in thick), 405 lb total, bar resting on the floor." ;;
    trap-bar-deadlift)
      # 335 lb — heavy, bumpers.
      echo "Equipment: Rogue TB-1 Trap Bar — a hexagonal-frame barbell where the lifter stands inside the frame, parallel grip handles on the sides, NOT a straight barbell — the bar must form a clear hexagonal shape, 1.5 m wide, 28 mm knurled grip, loaded with three 45 lb black rubber bumper plates on each side (450 mm / 17.7 in diameter, 74 mm / 2.9 in thick), 335 lb total." ;;
    overhead-press)
      # 135 lb — light, iron with mixed diameters (real OHP loading: 45 + 25 + 10).
      echo "Equipment: Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m, 28 mm grip), loaded with one 45 lb cast iron plate, one 25 lb cast iron plate, and one 10 lb cast iron plate on each side (the 45s are 17.5 in diameter, the 25s are 11 in diameter, the 10s are 9 in diameter — visible diameter change as you go outward from the center, exactly how real iron plates are loaded), 160 lb total of cast iron, bar racked at collarbone height with elbows tucked." ;;
    romanian-deadlift)
      # 225 lb — moderate, iron.
      echo "Equipment: Rogue Ohio Power Bar stainless steel Olympic barbell (2.2 m, 28 mm grip), loaded with one 45 lb cast iron plate, one 25 lb cast iron plate, and one 10 lb cast iron plate on each side (the 45s are 17.5 in diameter, the 25s are 11 in diameter, the 10s are 9 in diameter — visible diameter change as you go outward from the center, exactly how real iron plates are loaded), 160 lb total of cast iron." ;;
    dumbbell-curl)
      echo "Equipment: pair of 50 lb adjustable dumbbells with black rubber hex heads, knurled steel handle." ;;
    *)
      return 0 ;;
  esac
}

# Lock the output aspect to anamorphic widescreen — matches the stills.
dimensions_args () {
  printf -- '--width 1440 --height 800 --aspect-ratio 16:9'
}