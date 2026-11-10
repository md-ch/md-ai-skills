#!/usr/bin/env bash
# GET <api-url>/object-creation?logId=<logid>
# usage: get-object-creation.sh --url <api-url> --token <api-token> --logid <logid>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-object-creation.sh --url <api-url> --token <api-token> --logid <logid>
EOF
  exit 2
}

url=""
token=""
logid=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --logid) logid="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$logid" ]]; then
  usage
fi

if [[ -z "$token" ]]; then
  usage
fi

if [[ ! "$logid" =~ ^[0-9]+$ ]] || [[ "$logid" -le 0 ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  --data-urlencode "logId=${logid}" \
  "${url}/object-creation"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
