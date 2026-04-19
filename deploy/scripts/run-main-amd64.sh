#!/usr/bin/env bash
set -euo pipefail

# Override APP_DIR/LOG_DIR from systemd Environment= if needed.
APP_DIR="${APP_DIR:-/opt/cbt-smpn2lawang}"
LOG_DIR="${LOG_DIR:-${APP_DIR}/logs}"

mkdir -p "${LOG_DIR}"
cd "${APP_DIR}"

exec "${APP_DIR}/main-amd64"
