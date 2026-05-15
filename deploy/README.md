# Lumelogics — single-VPS deployment runbook

Deploys all three apps to one Contabo VPS behind Caddy:

| App | Repo | URL | Internal |
|---|---|---|---|
| Rails API | `lumelogics-server` | `api.lumelogics.com` | `web:3001` |
| Admin portal | `lumelogics-portal` | `portal.lumelogics.com` | `portal:3000` |
| Marketing | `lumelogics-web` | `lumelogics.com` | `marketing:3000` |

Stack: `docker compose` (this `deploy/` dir's files) + Caddy (auto-HTTPS).
Secrets are provisioned **once, manually** to `/srv/lumelogics/.env`.

---

## 0. VPS prep (fresh Ubuntu LTS, as root)

```bash
adduser deploy && usermod -aG sudo deploy        # non-root sudo user
ufw allow OpenSSH && ufw allow 80 && ufw allow 443 && ufw --force enable
curl -fsSL https://get.docker.com | sh           # Docker Engine + compose plugin
usermod -aG docker deploy
mkdir -p /srv/lumelogics && chown deploy:deploy /srv/lumelogics
```

Recommended: disable SSH password/root login (key-only) in `/etc/ssh/sshd_config`.

## 1. DNS (Cloudflare — do the subdomains now, apex at cutover)

In the Cloudflare dashboard for `lumelogics.com`, **DNS only / grey cloud**:

| Type | Name | Content | When |
|---|---|---|---|
| A | `api` | `<VPS IP>` | now |
| A | `portal` | `<VPS IP>` | now |
| A | `@` (`lumelogics.com`) | `<VPS IP>` | **only at step 5 cutover** |
| CNAME | `www` | `lumelogics.com` | now (optional) |

A day before cutover, lower the existing apex `lumelogics.com` record's TTL to
**300 s** (Auto won't apply while proxied/grey — set explicitly) for fast
rollback. `api`/`portal` are brand-new so they carry zero risk.

## 2. Lay out the box

```bash
cd /srv/lumelogics
git clone <server-repo-url> server
git clone <portal-repo-url>  portal
git clone <web-repo-url>     web

# Orchestration files are version-controlled in server/deploy/ — copy them up:
cp server/deploy/docker-compose.prod.yml .
cp server/deploy/Caddyfile .
cp server/deploy/deploy.sh . && chmod +x deploy.sh
cp server/deploy/.env.production.example .env
```

Final layout: `/srv/lumelogics/{server,portal,web,docker-compose.prod.yml,Caddyfile,deploy.sh,.env}`.

## 3. Secrets

```bash
nano /srv/lumelogics/.env          # fill in EVERY CHANGE_ME
chmod 600 /srv/lumelogics/.env
```

Generate the two crypto secrets:

```bash
openssl rand -hex 64                                   # -> SECRET_KEY_BASE
ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"   # -> ADMIN_JWT_SECRET
```

Set a strong `POSTGRES_PASSWORD`, `ADMIN_PASSWORD`, a real `RESEND_API_KEY`
(+ verified `MAIL_FROM` domain), and `ACME_EMAIL`. The `NEXT_PUBLIC_*` lines
are already correct defaults — leave them.

## 4. Bring it up

```bash
cd /srv/lumelogics
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d db
docker compose -f docker-compose.prod.yml up -d web    # entrypoint runs db:prepare (create+migrate)
docker compose -f docker-compose.prod.yml exec web ./bin/rails db:seed   # admin user + playbook magnet
docker compose -f docker-compose.prod.yml up -d worker marketing portal caddy
docker compose -f docker-compose.prod.yml ps
```

Caddy needs a minute to obtain certs (watch `... logs -f caddy`).

## 5. Verify, then cut over

Test on the **new subdomains first** (apex still on the old host):

```bash
curl -I https://api.lumelogics.com/up                  # 200, valid cert
```

- `https://portal.lumelogics.com` → log in (`ADMIN_EMAIL`/`ADMIN_PASSWORD`),
  Dashboard counts load (proves CORS + API).
- Submit the free assessment on the marketing build, request a lead magnet end
  to end (verification email via Resend → access page → file download).

Then **cut over**: in Cloudflare change the `@` A record to the VPS IP. With
the pre-lowered TTL it propagates in minutes. Verify `https://lumelogics.com`.
Keep the old marketing host running ~24 h.

**Optional hardening (after a clean bake):** flip the Cloudflare records to
proxied (orange), SSL/TLS mode **Full (strict)**, and install a Cloudflare
Origin certificate in Caddy. Hides the origin IP, adds CDN/WAF.

## Ongoing deploys

```bash
cd /srv/lumelogics && ./deploy.sh
```

Pulls all repos, `pg_dump` backup → `backups/`, rebuilds, `up -d`, migrates.
Frontends are rebuilt every run because `NEXT_PUBLIC_*` is baked at build time.

## Rollback

- **Marketing**: repoint the Cloudflare `@` A record to the old host (TTL was
  lowered). `api`/`portal` are new — nothing to roll back.
- **App**: `docker compose -f docker-compose.prod.yml down`, `git -C server
  checkout <good-sha>` (etc.), redeploy.
- **DB**: restore the latest `backups/db-*.sql.gz`
  (`gunzip -c … | docker compose -f docker-compose.prod.yml exec -T db psql -U lumelogics lumelogics_production`).

## Notes / gotchas

- **`assume_ssl`**: Rails has `force_ssl` + `assume_ssl` (set in
  `config/environments/production.rb`); Caddy terminates TLS and speaks plain
  HTTP to Puma. Both are required together or you get an HTTPS redirect loop.
- **Host allow-list**: `production.rb` allows `api.lumelogics.com` + localhost;
  add more via the `ADDITIONAL_HOSTS` env (comma-separated) — no code change.
- **Uploads** (`public/uploads`, CarrierWave lead-magnet files) live on the
  `uploads` named volume + `RAILS_SERVE_STATIC_FILES=1` — they survive
  redeploys. Include the volume in any real backup story.
- **Marketing `/v/<slug>`** is server-rendered, so the `marketing` container
  fetches `https://api.lumelogics.com` itself. That hairpins out through
  Cloudflare/Caddy and works; if the VPS can't reach its own public hostname,
  add an `extra_hosts` entry mapping `api.lumelogics.com` to the host/Caddy.
- **Postgres is never published** to the host — only Caddy binds 80/443.
- Fresh DB assumed. If real production data exists elsewhere, load a dump
  before going live.
