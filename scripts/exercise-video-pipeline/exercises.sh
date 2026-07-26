#!/usr/bin/env bash
# exercises.sh — the exercise catalogue.
#
# Each entry: slug | display name | start-pose description | rep action description.
#
# start_pose:  the EXACT pose the video's first and last frames must show
#              (equipment already in hand/body, starting position).
#              The anchor image is generated from this; the video starts
#              from the anchor and ends back at the anchor — for a seamless
#              loop.
#
# action:      motion description for one rep, ending where it started.
#
# The slug must match a case in equipment_block() in prompts.sh.
# Equipment specs (brand, dimensions, plate count, weight) are NOT in
# this file — they live in prompts.sh and are auto-injected by slug.
# Both camera angles of an exercise share the same equipment, so the
# load is identical in the front and side view.

set -euo pipefail

EXERCISES=(
  # Curl with a straight Olympic barbell (Rogue Ohio Power Bar).
  "barbell-curl|Standing Barbell Curl|standing upright, feet shoulder-width apart, arms fully extended at sides supinated grip on the bar, bar hanging in front of the thighs, neutral focused expression|concentric phase curling the barbell upward keeping elbows pinned at the sides until forearms are vertical, then eccentric phase lowering the barbell under control until arms are fully extended, returning to the starting position"

  # Curl with an EZ-curl bar (Rogue ZEUS) — different bar type, more wrist-friendly.
  "ez-curl|Standing EZ-Bar Curl|standing upright, feet shoulder-width apart, supinated grip on the angled handles of the EZ-curl bar, arms fully extended down in front of the thighs, neutral focused expression|concentric phase curling the EZ-curl bar upward keeping upper arms pinned to the torso until forearms are vertical, then eccentric phase lowering under control until arms are fully extended, returning to the starting position"

  # Back squat with straight Olympic barbell.
  "back-squat|Back Squat|standing upright, feet shoulder-width apart, Olympic barbell racked across the upper trapezius gripped with both hands, neutral focused expression|eccentric phase descending by bending hips and knees until thighs are parallel to the floor, then concentric phase driving through the feet and extending hips and knees to return to the standing position"

  # Flat bench press with straight Olympic barbell.
  "bench-press|Bench Press|lying flat on the bench, feet planted on the floor, hands supinated gripping the barbell at full arm extension directly over the chest, neutral focused expression|eccentric phase lowering the barbell under control until the bar lightly touches mid-chest, then concentric phase pressing the bar back up until arms are fully extended, returning to the starting position"

  # Conventional deadlift with straight Olympic barbell.
  "deadlift|Conventional Deadlift|standing upright behind the barbell, feet hip-width apart, hinged at the hips with alternating grip on the bar, bar loaded and resting on the floor, neutral focused expression|concentric phase lifting the bar by extending hips and knees until standing upright with shoulders back, then eccentric phase lowering the bar under control until it returns to the floor, returning to the starting position"

  # Trap bar / hex bar deadlift (Rogue TB-1) — different bar type, neutral spine.
  "trap-bar-deadlift|Trap Bar Deadlift|standing inside the hexagonal frame of the trap bar, feet shoulder-width apart, gripping the parallel handles, trap bar loaded and resting on the floor, neutral focused expression|concentric phase lifting the trap bar by extending hips and knees until standing upright, then eccentric phase lowering under control until the trap bar returns to the floor, returning to the starting position"

  # Standing overhead press with straight Olympic barbell.
  "overhead-press|Overhead Press|standing upright, feet shoulder-width apart, Olympic barbell racked at collarbone height with elbows tucked and hands just outside shoulder width, neutral focused expression|concentric phase pressing the bar straight overhead until arms are fully extended, then eccentric phase lowering back to collarbone height, returning to the starting position"

  # Romanian deadlift with straight Olympic barbell.
  "romanian-deadlift|Romanian Deadlift|standing upright, feet hip-width apart, overhand grip on the barbell resting against the front of the thighs, neutral focused expression|eccentric phase hinging at the hips with a slight bend in the knees, lowering the bar along the front of the legs until the torso is roughly parallel to the floor, then concentric phase driving the hips forward to return to the standing position"
)

# Field accessors
slug_for ()    { echo "$1" | cut -d'|' -f1; }
name_for ()    { echo "$1" | cut -d'|' -f2; }
pose_for ()    { echo "$1" | cut -d'|' -f3; }
action_for ()  { echo "$1" | cut -d'|' -f4-; }