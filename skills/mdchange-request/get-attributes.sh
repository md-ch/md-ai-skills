#!/usr/bin/env bash
# GET <api-url>/attributes?appl=<appl>&lvl=<lvl>&objt=<objt>
# usage: get-attributes.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> [--objt <objt>]
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-attributes.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> [--objt <objt>]
EOF
  exit 2
}

url=""
token=""
appl=""
lvl=""
objt=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --lvl) lvl="${2:-}"; shift 2 ;;
    --objt) objt="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$token" || -z "$appl" || -z "$lvl" ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

query="appl=${appl}&lvl=${lvl}"
if [[ -n "$objt" ]]; then
  query="${query}&objt=${objt}"
fi

curl -sS --connect-timeout 10 --max-time 30 -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  -d "$query" \
  "${url}/attributes"

status="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status"
cat "$body"
printf '\n'
