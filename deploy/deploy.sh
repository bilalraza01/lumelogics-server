#!/usr/bin/env bash
# Re-deploy the Lumelogics stack: pull all 3 repos, back up the DB, rebuild,
# bring up, migrate. Run from /srv/lumelogics (where .env + compose live).
#
#   ./deploy.sh            # full: all repos + all services
#   ./deploy.sh server     # only rebuild the backend (still pulls all)

set -euo pipefail
cd "$(dirname "$0")"

COMPOSE="docker compose -f docker-compose.prod.yml"

# Load .env so $POSTGRES_* are available for the backup step.
set -a
# shellcheck disable=SC1091
[ -f .env ] && . ./.env
set +a

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
