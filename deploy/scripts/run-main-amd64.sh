#!/usr/bin/env bash
set -euo pipefail

# Allow local/manual execution by defaulting APP_DIR to repo root.
# systemd can still override APP_DIR/LOG_DIR via Environment=.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
APP_DIR="${APP_DIR:-${REPO_DIR}}"
LOG_DIR="${LOG_DIR:-${APP_DIR}/logs}"

mkdir -p "${LOG_DIR}"
cd "${APP_DIR}"

if [[ ! -x "${APP_DIR}/main-amd64" ]]; then
  echo "main-amd64 not found or not executable at: ${APP_DIR}/main-amd64" >&2
  exit 1
fi

exec "${APP_DIR}/main-amd64"
