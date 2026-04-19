# Deploy `main-amd64` as a background service + Nginx HTTPS proxy

This repo now includes:

- `deploy/scripts/run-main-amd64.sh` (runner)
- `deploy/systemd/main-amd64.service` (systemd template)
- `deploy/nginx/cbt-main-amd64.conf` (Nginx reverse-proxy template)
- `deploy/.env.reverse-proxy.example` (env values for proxy mode)

## 1) Prepare app environment

1. Ensure `main-amd64` is executable:
   `chmod +x main-amd64`
2. In root `.env`, set at least:
   - `SERVER_HOST=127.0.0.1`
   - `SERVER_PORT=9988`
   - `SERVER_BEHIND_PROXY=true`
   - `STORAGE_PATH=./storage`
3. Ensure log directory exists:
   `mkdir -p logs`

## 2) Install systemd service

Set variables:

```bash
REPO_PATH=/absolute/path/to/this/repo
RUN_USER=your-linux-user
RUN_GROUP=your-linux-group
```

Create the final unit:

```bash
sudo sed \
  -e "s|__REPO_PATH__|$REPO_PATH|g" \
  -e "s|__RUN_USER__|$RUN_USER|g" \
  -e "s|__RUN_GROUP__|$RUN_GROUP|g" \
  "$REPO_PATH/deploy/systemd/main-amd64.service" \
  | sudo tee /etc/systemd/system/main-amd64.service >/dev/null
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now main-amd64
sudo systemctl status main-amd64
```

Logs are written to:

`<repo>/logs/main-amd64.log`

## 3) Install Nginx config for HTTPS domain

Set variables:

```bash
REPO_PATH=/absolute/path/to/this/repo
DOMAIN=your.domain.com
```

Install site config:

```bash
sudo sed "s|__DOMAIN_NAME__|$DOMAIN|g" \
  "$REPO_PATH/deploy/nginx/cbt-main-amd64.conf" \
  | sudo tee /etc/nginx/sites-available/$DOMAIN.conf >/dev/null
sudo ln -sf /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/$DOMAIN.conf
```

Test and reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

If SSL cert files are not present yet, create them first (example with Certbot):

```bash
sudo certbot --nginx -d $DOMAIN
```
