#!/usr/bin/env bash
# POST <api-url>/rfp-dependencies
# usage: post-rfp-dependencies.sh --url <api-url> --token <api-token> --appl <appl> --rfp <rfp> --clear-existing <clear-existing>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: post-rfp-dependencies.sh --url <api-url> --token <api-token> --appl <appl> --rfp <rfp> --clear-existing <clear-existing>
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
clear_existing=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --rfp) rfp="${2:-}"; shift 2 ;;
    --clear-existing) clear_existing="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$appl" || -z "$rfp" || -z "$clear_existing" ]]; then
  usage
fi

if [[ -z "$token" ]]; then
  usage
fi

url="${url%/}"

payload="$(printf '{"appl":"%s","rfp":"%s","clearExisting":"%s"}' \
  "$(json_escape "$appl")" \
  "$(json_escape "$rfp")" \
  "$(json_escape "$clear_existing")")"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -X POST -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  --data "$payload" \
  "${url}/rfp/dependencies"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
