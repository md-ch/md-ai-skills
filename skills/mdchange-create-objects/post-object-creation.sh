#!/usr/bin/env bash
# POST <api-url>/object-creation
# usage: post-object-creation.sh --url <api-url> --token <api-token> --appl <appl> --rfp <rfp> --from-first-missing <*NO|*YES> --stop-when-error <*NO|*YES>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: post-object-creation.sh --url <api-url> --token <api-token> --appl <appl> --rfp <rfp> --from-first-missing <*NO|*YES> --stop-when-error <*NO|*YES>
EOF
  exit 2
}

json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

url=""
token=""
appl=""
rfp=""
from_first_missing=""
stop_when_error=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --rfp) rfp="${2:-}"; shift 2 ;;
    --from-first-missing) from_first_missing="${2:-}"; shift 2 ;;
    --stop-when-error) stop_when_error="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$appl" || -z "$rfp" || -z "$from_first_missing" || -z "$stop_when_error" ]]; then
  usage
fi

if [[ -z "$token" ]]; then
  usage
fi

if [[ "$from_first_missing" != "*NO" && "$from_first_missing" != "*YES" ]]; then
  usage
fi

if [[ "$stop_when_error" != "*NO" && "$stop_when_error" != "*YES" ]]; then
  usage
fi

url="${url%/}"

payload="$(printf '{"appl":"%s","rfp":"%s","fromFirstMissing":"%s","stopWhenError":"%s"}' \
  "$(json_escape "$appl")" \
  "$(json_escape "$rfp")" \
  "$(json_escape "$from_first_missing")" \
  "$(json_escape "$stop_when_error")")"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -X POST -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  --data "$payload" \
  "${url}/object-creation"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
