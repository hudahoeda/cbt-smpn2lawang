# Deploy `main-amd64` with systemd + Coolify app Nginx proxy

This repo includes:

- `deploy/scripts/run-main-amd64.sh` (runner)
- `deploy/systemd/main-amd64.service` (systemd unit template)
- `deploy/nginx/cbt-main-amd64.conf` (Coolify app-container Nginx template)
- `deploy/nginx/cbt-main-amd64.host.conf` (host-level Nginx template)
- `deploy/.env.reverse-proxy.example` (recommended env values)

## 1) Prepare app environment

1. Ensure binary is executable:
   `chmod +x main-amd64`
2. In root `.env`, set at least:
   - `SERVER_HOST=0.0.0.0`
   - `SERVER_PORT=9988`
   - `SERVER_BEHIND_PROXY=true`
   - `SERVER_PROXY_REAL_API_HEADER=X-Forwarded-For`
   - `STORAGE_PATH=./storage`
3. Ensure log directory exists:
   `mkdir -p logs`

Why `0.0.0.0`:
Coolify app Nginx runs in Docker and reaches host service via gateway `10.0.1.1:9988`.

## 2) Install systemd service

Set variables:

```bash
REPO_PATH=/absolute/path/to/this/repo
RUN_USER=your-linux-user
RUN_GROUP=your-linux-group
```

Create and enable unit:

```bash
sudo sed \
  -e "s|__REPO_PATH__|$REPO_PATH|g" \
  -e "s|__RUN_USER__|$RUN_USER|g" \
  -e "s|__RUN_GROUP__|$RUN_GROUP|g" \
  "$REPO_PATH/deploy/systemd/main-amd64.service" \
  | sudo tee /etc/systemd/system/main-amd64.service >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable --now main-amd64
sudo systemctl status --no-pager --lines=25 main-amd64
```

Verify bind:

```bash
ss -ltnp | rg ':9988\b'
```

Expected: listener on `0.0.0.0:9988` (or your host IP), not only `127.0.0.1`.

## 3) Apply Nginx config to Coolify app container

Set variables:

```bash
DOMAIN=your.domain.com
REPO_PATH=/absolute/path/to/this/repo
APP_SLUG=your-coolify-app-slug
APP_NAME="$(sudo docker ps --format '{{.Names}}' | grep -E "^${APP_SLUG}-" | head -n1)"
LIVE_CONF="/data/coolify/applications/${APP_SLUG}/etc/nginx/${DOMAIN}.conf"
```

Render template to Coolify persistent config:

```bash
sudo sed "s|__DOMAIN_NAME__|$DOMAIN|g" \
  "$REPO_PATH/deploy/nginx/cbt-main-amd64.conf" \
  | sudo tee "$LIVE_CONF" >/dev/null
```

Push same config to running app container and reload:

```bash
sudo sed "s|__DOMAIN_NAME__|$DOMAIN|g" \
  "$REPO_PATH/deploy/nginx/cbt-main-amd64.conf" \
  | sudo docker exec -i "$APP_NAME" sh -lc 'cat > /etc/nginx/conf.d/default.conf'

sudo docker exec "$APP_NAME" nginx -t
sudo docker exec "$APP_NAME" nginx -s reload
```

## 4) Verify end-to-end

From app container to host service:

```bash
sudo docker exec "$APP_NAME" sh -lc "curl -sS -o /dev/null -w '%{http_code}\n' http://10.0.1.1:9988"
```

Public domain:

```bash
curl -I https://$DOMAIN
```

Both should return `200`.

## Troubleshooting

- If you still get `Welcome to nginx!`, config is not applied to the active app container instance.
- Coolify may recreate container names on deploy; re-resolve `APP_NAME` before running `docker exec`.
- If app container cannot reach `10.0.1.1:9988`, re-check root `.env` (`SERVER_HOST=0.0.0.0`) and restart `main-amd64`.

## Non-Coolify (host Nginx) mode

Use this mode when Nginx runs directly on host (not inside a Docker app container).

Recommended app bind:

- `SERVER_HOST=127.0.0.1`
- `SERVER_PORT=9988`

Apply host Nginx template:

```bash
DOMAIN=your.domain.com
REPO_PATH=/absolute/path/to/this/repo

sudo sed "s|__DOMAIN_NAME__|$DOMAIN|g" \
  "$REPO_PATH/deploy/nginx/cbt-main-amd64.host.conf" \
  | sudo tee /etc/nginx/sites-available/$DOMAIN.conf >/dev/null

sudo ln -sf /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/$DOMAIN.conf
sudo nginx -t
sudo systemctl reload nginx
```

Mode summary:

- Coolify app-container Nginx: use `deploy/nginx/cbt-main-amd64.conf` and `SERVER_HOST=0.0.0.0`.
- Host Nginx: use `deploy/nginx/cbt-main-amd64.host.conf` and `SERVER_HOST=127.0.0.1`.
