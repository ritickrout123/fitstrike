# FitStrike Backend

This package contains the initial backend foundation for FitStrike.

## Included in the Foundation

- Express app bootstrap
- Versioned API router under `/v1`
- Domain-aligned route modules
- Socket.IO server bootstrap
- Environment configuration
- Local Docker support for MongoDB, Redis, and PostGIS

## Run Locally

```bash
cp .env.example .env
npm install
npm run dev
```

## Current Status

The route handlers currently return placeholder responses so we can lock structure and contracts before deeper implementation work begins.
