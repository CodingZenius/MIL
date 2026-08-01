# FitPulse

A Material 3 ("Android 16" style) fitness app: bold typography, dynamico
color, bright blue/red on near-black, circular activity rings on the
dashboard, rectangular cards for detail stats, and swipeable Home →
Hydration → Nutrition pages.

## What's implemented

- **Onboarding** (`lib/screens/onboarding_screen.dart`): name, height,
  weight, goal — 3-step swipeable flow, saved to Hive.
- **Personalization**: `UserProfile.dailyCalorieBurn` (Mifflin-St Jeor BMR
  × activity factor, nudged by goal) in `lib/models/user_profile.dart`.
- **Home dashboard**: large multi-ring `ActivityRing` widget (steps /
  distance / calories) plus `StatCard` rectangular detail tiles.
- **Active Mode** (`lib/screens/running_screen.dart`): full-screen looping
  video background with a live metrics overlay (distance, pace, calories,
  time). Falls back to a gradient if no video asset is present.
- **Auto run-detection** (`lib/services/activity_service.dart`):
  accelerometer variance + GPS speed heuristic; `HomeScreen` auto-pushes
  `RunningScreen` when it detects running.
- **Hydration & Nutrition screens**: swipeable from Home, with their own
  rotating tip cards.
- **"Dead backend" content model** (`lib/services/content_service.dart`):
  ships with `assets/content/tips.json` so the app works fully offline
  from first launch, and opportunistically fetches a newer JSON from a
  static URL you control — no server code to run or maintain.
- **Daily rotating tip**: deterministic pick based on day-of-year, so
  every user sees the same tip on a given day and it changes at midnight.
- **Local storage**: Hive box for the user profile (works fully offline
  once onboarding is done); SharedPreferences cache for content JSON.

## Wiring up your own content updates

1. Host a JSON file anywhere static (raw GitHub file, S3, Cloudflare R2,
   a GitHub Gist, etc.) with the same shape as `assets/content/tips.json`.
2. Bump the `"version"` field whenever you change the cards.
3. Point `ContentService.remoteContentUrl` at that file's raw URL.

That's the entire "backend" — no server process, no database, no auth.

## Adding the running-mode video

Drop a silent, looping MP4 at `assets/videos/running_loop.mp4`
(see `assets/videos/PUT_VIDEO_HERE.md`). The app builds and runs fine
without it too — it just falls back to a gradient background.

## Building the APK via GitHub Actions

This repo intentionally does **not** commit the `android/` platform
folder. `.github/workflows/build_apk.yml`:

1. Installs Java 17 + Flutter (stable channel).
2. Runs `flutter create --platforms=android .` to scaffold `android/`
   using whatever Flutter/AGP/Gradle versions the CI runner currently
   ships — this avoids version-drift breakage between your machine and
   CI over time.
3. Runs `scripts/patch_android_manifest.sh` to add the permissions the
   app needs (INTERNET, location, activity recognition, wake lock).
4. `flutter pub get` then `flutter build apk --release`.
5. Uploads `app-release.apk` as a workflow artifact.

To trigger it: push this repo to GitHub (main or master branch), or run
it manually from the **Actions** tab via "Run workflow". Download the
APK from the finished run's **Artifacts** section.

### If you'd rather commit android/ yourself

Run `flutter create --platforms=android .` locally once, commit the
resulting `android/` folder, remove it from `.gitignore`, and delete the
"Generate platform folders" step from the workflow (keep the manifest
patch step, or fold those permissions into your committed manifest by
hand instead).

## Local development

```bash
flutter create --platforms=android,ios . # first time only
flutter pub get
flutter run
```

## Notes / next steps for a production build

- Replace the placeholder step-count/distance numbers on the dashboard
  (`HomeScreen._steps` etc.) with a real pedometer / Health Connect /
  HealthKit integration.
- The accelerometer+GPS run-detection thresholds in `ActivityService`
  are heuristic starting points — tune `_windowSize` and the variance
  thresholds against real device data.
- Add a proper app icon / splash screen once `android/` is generated
  (via `flutter_launcher_icons` or manually).
