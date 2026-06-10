# Ping Tracker

Simple uptime/ping tracker for URLs and hosts with quick checks and grouped entries.

## Structure

- `lib/controllers`: state management (entries, settings)
- `lib/models`: data models (`TrackEntry`, `AppSettings`, `CheckVisual`)
- `lib/services`: network/tcp checks (`CheckService`)
- `lib/widgets`: reusable UI components (EntryCard, QuickInput, etc.)
- `lib/screens`: standalone screens (settings)

## Run

1. Flutter SDK installed
2. Get packages
3. Run

## Notes

- Uses Hive for local storage
- Material 3 + Google Fonts for styling
