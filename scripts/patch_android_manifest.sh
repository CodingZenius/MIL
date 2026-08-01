#!/usr/bin/env bash
# Adds the permissions FitPulse needs (location for GPS pace/distance,
# activity recognition for run detection, internet for the optional
# "dead backend" content refresh) into the AndroidManifest.xml that
# `flutter create` scaffolds. Idempotent: safe to re-run.
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"

if [ ! -f "$MANIFEST" ]; then
  echo "AndroidManifest.xml not found at $MANIFEST — skipping patch."
  exit 0
fi

add_permission() {
  local perm="$1"
  if ! grep -q "$perm" "$MANIFEST"; then
    # Insert right after the opening <manifest ...> tag line.
    awk -v perm="    <uses-permission android:name=\"$perm\" />" '
      { print }
      /<manifest / && !done { print perm; done=1 }
    ' "$MANIFEST" > "$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"
    echo "Added $perm"
  else
    echo "$perm already present"
  fi
}

add_permission "android.permission.INTERNET"
add_permission "android.permission.ACCESS_FINE_LOCATION"
add_permission "android.permission.ACCESS_COARSE_LOCATION"
add_permission "android.permission.ACTIVITY_RECOGNITION"
add_permission "android.permission.WAKE_LOCK"

cat "$MANIFEST"
