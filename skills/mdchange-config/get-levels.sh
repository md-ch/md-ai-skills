#!/usr/bin/env bash
# GET <api-url>/levels?checkoutAllowed=<true|false>
# usage: get-levels.sh --url <api-url> --token <api-token> --checkout-allowed <true|false>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-levels.sh --url <api-url> --token <api-token> --checkout-allowed <true|false>
EOF
  exit 2
}

url=""
token=""
checkout=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --checkout-allowed) checkout="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$token" || -z "$checkout" ]]; then
  usage
fi

case "$checkout" in
  true|false) ;;
  *) echo "checkout-allowed must be true or false" >&2; exit 2 ;;
esac

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  "${url}/levels?checkoutAllowed=${checkout}"

status="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status"
cat "$body"
printf '\n'
