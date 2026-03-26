# FitStrike

FitStrike is a gamified fitness platform that combines workout tracking, territory capture, progression systems, and social competition.

This repository is now set up as a greenfield monorepo foundation for the first implementation phase:

- `mobile/`: Flutter app shell and feature-first structure
- `backend/`: Node.js + Express + Socket.IO API foundation
- `docs/`: product, architecture, and prototype source material
- `infrastructure/`: local container and environment setup

## Current Foundation

The initial setup is aligned to the project docs and prototype:

- Flutter + Flame + Riverpod on mobile
- Node.js + Express + Socket.IO on backend
- MongoDB + Redis + PostGIS in local development
- Feature-first structure that mirrors the prototype flows

The current in-memory foundation already includes working backend contracts and mobile data wiring for:

- auth and current-user session bootstrap
- session persistence and route guards on mobile
- today dashboard snapshot
- gym plan loading plus exercise completion
- nutrition loading plus quick-add meal logging
- territory run overview and simulated capture
- clans, comms, events, and leaderboard reads

## Repo Layout

```text
FitStrike/
├── backend/
├── docs/
├── infrastructure/
└── mobile/
```

## Local Development

### Backend

1. Copy `backend/.env.example` to `backend/.env`
2. Start supporting services with Docker Compose
3. Install backend dependencies
4. Run the API server

```bash
docker compose up -d mongo redis postgis
cd backend
npm install
npm run dev
```

The current backend uses in-memory services, so Docker is optional for this checkpoint run. It becomes useful once we swap in MongoDB, Redis, and PostGIS-backed repositories.

### Mobile

Flutter is not installed in the current workspace, so the mobile app has been scaffolded manually to keep moving.

When Flutter is available:

```bash
cd mobile
flutter pub get
flutter create .
flutter run
```

`flutter create .` is intended here to generate the missing native platform folders around the existing app structure.

## Source of Truth

- Product strategy: `docs/FitStrikeDELIVERABLE1.md`
- Technical architecture: `docs/FitStrikeDELIVERABLES2.md`
- Stack guidance: `docs/tech_stack.md`
- End-to-end UX prototype: `docs/fitstrike.html`

## Next Recommended Build Steps

1. Install Flutter locally and complete the mobile bootstrap.
2. Replace the in-memory backend store with Mongo-backed repositories.
3. Turn the run/map slice into a real GPS flow with geospatial persistence and anti-cheat checks.
4. Layer live sockets, notifications, and push-driven refresh onto the community and event flows.
