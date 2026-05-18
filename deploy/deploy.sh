#!/usr/bin/env bash
# Re-deploy the Lumelogics stack: pull all 3 repos, back up the DB, rebuild,
# bring up, migrate. Run from /srv/lumelogics (where .env + compose live).
#
#   ./deploy.sh            # full: all repos + all services
#   ./deploy.sh server     # only rebuild the backend (still pulls all)

set -euo pipefail
cd "$(dirname "$0")"

COMPOSE="docker compose -f docker-compose.prod.yml"

# Pull just the Postgres identifiers for the backup step. We deliberately do
# NOT `source` .env: docker compose parses it natively, but values like
# MAIL_FROM="Name <addr>" are not valid shell and would abort this script.
envval() { [ -f .env ] && grep -E "^$1=" .env | tail -1 | cut -d= -f2- | tr -d "\"'\r"; }
POSTGRES_USER="$(envval POSTGRES_USER)"
POSTGRES_DB="$(envval POSTGRES_DB)"

echo "==> Pulling repos"
for d in server portal web; do
  if [ -d "$d/.git" ]; then
    git -C "$d" pull --ff-only
  else
    echo "   (skip $d — not a git checkout)"
  fi
done

echo "==> Backing up Postgres"
mkdir -p backups
if $COMPOSE ps db --status running -q | grep -q .; then
  $COMPOSE exec -T db pg_dump -U "${POSTGRES_USER:-lumelogics}" "${POSTGRES_DB:-lumelogics_production}" \
    | gzip > "backups/db-$(date +%Y%m%d-%H%M%S).sql.gz"
  # Keep the 14 most recent dumps.
  ls -1t backups/db-*.sql.gz 2>/dev/null | tail -n +15 | xargs -r rm --
else
  echo "   (db not running yet — skipping backup)"
fi

echo "==> Build + up"
$COMPOSE build "$@"
$COMPOSE up -d

echo "==> Migrating database"
$COMPOSE exec -T web ./bin/rails db:migrate

echo "==> Status"
$COMPOSE ps
echo "==> Done."
