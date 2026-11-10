#!/usr/bin/env bash
# GET <api-url>/object-creation/spoolfile?objectId=<objectid>
# usage: get-object-creation-spoolfile.sh --url <api-url> --token <api-token> --objectid <objectid>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-object-creation-spoolfile.sh --url <api-url> --token <api-token> --objectid <objectid>
EOF
  exit 2
}

url=""
token=""
objectid=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --objectid) objectid="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$objectid" ]]; then
  usage
fi

if [[ -z "$token" ]]; then
  usage
fi

if [[ ! "$objectid" =~ ^[0-9]+$ ]] || [[ "$objectid" -le 0 ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: text/plain" \
  --data-urlencode "objectId=${objectid}" \
  "${url}/object-creation/spoolfile"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
