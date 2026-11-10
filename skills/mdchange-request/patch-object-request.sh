#!/usr/bin/env bash
# PATCH <api-url>/object-request
# usage: patch-object-request.sh --url <api-url> --token <api-token> --object-id <object-id> --full-path <full-path> --gfile <gfile>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: patch-object-request.sh --url <api-url> --token <api-token> --object-id <object-id> --full-path <full-path> --gfile <gfile>
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
object_id=""
full_path=""
gfile=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --object-id) object_id="${2:-}"; shift 2 ;;
    --full-path) full_path="${2:-}"; shift 2 ;;
    --gfile) gfile="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$token" || -z "$object_id" || -z "$full_path" || -z "$gfile" ]]; then
  usage
fi

url="${url%/}"

target="$full_path"
if command -v cygpath >/dev/null 2>&1; then
  target="$(cygpath -u "$full_path")"
fi
cd "$(dirname "$target")"

payload="$(printf '{"objectId":"%s","gfile":"%s"}' "$(json_escape "$object_id")" "$(json_escape "$gfile")")"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -X PATCH -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: multipart/mixed" \
  -F "payload=${payload};type=application/json" \
  -F "file=@${gfile}" \
  "${url}/object-request"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
