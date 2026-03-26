# FitStrike Mobile

This is the Flutter client foundation for FitStrike.

The structure follows the architecture defined in the project docs:

- feature-first folders
- shared config and theme setup
- service placeholders for GPS, sockets, notifications, and audio
- an app shell that maps to the prototype's major flows

## Bootstrap

Flutter is not installed in the current workspace, so the project was scaffolded manually.

When Flutter is available:

```bash
flutter pub get
flutter create .
flutter run
```

## Foundation Scope

The current app shell includes:

- login entry
- today overview
- gym plan
- nutrition
- territory run
- social hub
- profile
- event screen

These are intentionally lightweight placeholders so we can stabilize navigation and structure before implementing production logic.
