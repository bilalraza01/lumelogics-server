# Lumelogics Assessment API

Rails 7.2 API backing the AI Readiness Assessment at `lumelogics.com/free-assessment`. Stores submissions, scores them, emails results via Resend, and exposes a JWT-protected admin endpoint for CRM export.

Spec: see `../lumelogics-web/ai_readiness_assessment_spec.md`.

## Stack

- Ruby 3.2 / Rails 7.2 in API-only mode
- PostgreSQL 15 (Docker)
- GoodJob (Postgres-backed background queue)
- Resend (transactional email)
- JWT for admin auth
- RSpec + FactoryBot

## Running it locally

Everything runs via Docker Compose — no Ruby/Postgres needed on the host.

```bash
cp .env.example .env             # fill in RESEND_API_KEY + ADMIN_JWT_SECRET
docker compose build
docker compose run --rm web bin/rails db:create db:migrate
docker compose up
```

Services:

| Service | Host port | Purpose |
|---|---|---|
| `web`    | `3001` | Rails API |
| `db`     | `5433` | PostgreSQL 15 (avoids the host's :5432) |
| `worker` | —      | GoodJob worker that drains the email queue |

The frontend at `lumelogics-web` should point at `http://localhost:3001` via `NEXT_PUBLIC_ASSESSMENT_API_URL`.

## Useful commands

```bash
docker compose run --rm web bin/rails console
docker compose run --rm web bundle exec rspec
docker compose run --rm web bin/rails admin:token            # generate JWT
docker compose run --rm web bin/rails admin:token EXPIRES_IN_DAYS=30
docker compose logs -f web worker
```

## API endpoints

All under `/api/v1/`. JSON in/out.

### `POST /api/v1/assessments`

Create + score + queue email.

```bash
curl -X POST http://localhost:3001/api/v1/assessments \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "owner@example.com",
    "answers": {
      "q1": 5, "q2": 3, "q3": 0, "q4": 5, "q5": 3,
      "q6": 4, "q7": 3, "q8": 5, "q9": 5, "q10": 3,
      "q11": 5, "q12": 3, "q13": 3, "q14": 3, "q15": 5,
      "q16": 5, "q17": 3, "q18": 5
    },
    "referral_source": "linkedin"
  }'
```

Returns 201 with `result_token`, `total_score`, `archetype`, `verdict`, `cta`, `dimension_scores`, `results_url`. Duplicate submission (same email within 1 hour) returns 200 with the existing record.

### `GET /api/v1/assessments/:token`

Fetch a previously-submitted assessment by `result_token`. 404 if not found.

### `GET /api/v1/admin/assessments`

JWT-protected. Pass `Authorization: Bearer <token>` issued via `bin/rails admin:token`.

Query params:
- `page` (default 1)
- `per_page` (default 50, max 200)
- `archetype` (optional filter)
- `from` / `to` (ISO dates)

## Env vars

See `.env.example`. Required at runtime:

| Var | Required | Notes |
|---|---|---|
| `DATABASE_URL` | yes | set by `docker-compose.yml` |
| `ADMIN_JWT_SECRET` | yes | random 64+ char hex string |
| `RESEND_API_KEY` | for real sends | when unset, emails are logged to stdout instead |
| `MAIL_FROM` | yes (for sends) | must be a verified Resend address |
| `ALLOWED_ORIGINS` | yes | CSV of frontend origins for CORS |
| `FRONTEND_URL` | optional | base URL embedded in the results email link |

## Tests

```bash
docker compose run --rm web bundle exec rspec
```

Coverage targets the spec's §4.7:
- `AssessmentScorer` — archetype boundary tests (35→Wishful, 36→Aspirational, …)
- `Api::V1::AssessmentsController` — happy path, invalid email, missing answers, duplicate within 1 hour, 404 by token
- `Api::V1::Admin::AssessmentsController` — 401 without/with bad JWT, list shape, archetype filter
- `AssessmentEmailJob` — calls the sender with the right assessment

## Deployment

Two Dockerfiles ship with the repo:
- `Dockerfile` — the dev-friendly one (used by `docker-compose.yml`)
- `Dockerfile.production` — the multi-stage Kamal-style one Rails generated; use this on Railway/Render/Fly

Pick whichever your host prefers. Typical env vars to set in production:

```
DATABASE_URL=postgres://...
RAILS_ENV=production
RAILS_MASTER_KEY=<from config/master.key>
SECRET_KEY_BASE=<openssl rand -hex 64>
ADMIN_JWT_SECRET=<openssl rand -hex 64>
RESEND_API_KEY=re_...
MAIL_FROM=Bilal at Lumelogics <bilal@lumelogics.com>
ALLOWED_ORIGINS=https://lumelogics.com
FRONTEND_URL=https://lumelogics.com
```

Don't forget to run `bin/rails db:migrate` on first deploy.
