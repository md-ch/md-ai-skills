#!/usr/bin/env bash
# GET <api-url>/git-repositories
# usage: get-git-repositories.sh --url <api-url> --token <api-token>
#        get-git-repositories.sh --token <api-token> --env-file <path>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-git-repositories.sh --url <api-url> --token <api-token>
       get-git-repositories.sh --token <api-token> --env-file <path>
EOF
  exit 2
}

url=""
token=""
env_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --env-file) env_file="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -n "$env_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$env_file"
  set +a
  url="${url:-${MDCMS_API_URL:-}}"
fi

if [[ -z "$url" || -z "$token" ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  "${url}/git-repositories"

status="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status"
cat "$body"
printf '\n'
