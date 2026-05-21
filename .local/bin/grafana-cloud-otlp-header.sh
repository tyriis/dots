#!/bin/sh
# Returns Grafana Cloud OTLP headers as JSON
# Called by opencode-plugin-otel via OPENCODE_OTLP_HEADERS_HELPER
set -e

CREDENTIALS_FILE="$HOME/secrets/grafana-cloud-otlp-credentials"

if [ ! -r "$CREDENTIALS_FILE" ]; then
  printf '{"error":"credentials file not found"}' >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$CREDENTIALS_FILE"

if [ -z "$GRAFANA_OTLP_CREDENTIALS" ]; then
  printf '{"error":"GRAFANA_OTLP_CREDENTIALS not set"}' >&2
  exit 1
fi

BASIC_TOKEN=$(printf '%s' "$GRAFANA_OTLP_CREDENTIALS" | base64)
printf '{"Authorization":"Basic %s"}' "$BASIC_TOKEN"
