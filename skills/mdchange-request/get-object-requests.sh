#!/usr/bin/env bash
# GET <api-url>/object-requests?appl=&lvl=&reason=&status=&repoId=&branch=&gpath=&gfile=
# usage: get-object-requests.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --reason <reason> --status <status> --repoId <repoId> --branch <branch> --gpath <gpath> --gfile <gfile>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-object-requests.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --reason <reason> --status <status> --repoId <repoId> --branch <branch> --gpath <gpath> --gfile <gfile>
EOF
  exit 2
}

url=""
token=""
appl=""
lvl=""
reason=""
status=""
repo_id=""
branch=""
gpath=""
gfile=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --lvl) lvl="${2:-}"; shift 2 ;;
    --reason) reason="${2:-}"; shift 2 ;;
    --status) status="${2:-}"; shift 2 ;;
    --repoId) repo_id="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --gpath) gpath="${2:-}"; shift 2 ;;
    --gfile) gfile="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$token" || -z "$appl" || -z "$lvl" || -z "$reason" || -z "$status" || -z "$repo_id" || -z "$branch" || -z "$gpath" || -z "$gfile" ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

MSYS2_ARG_CONV_EXCL='gpath=' curl -sS -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  --data-urlencode "appl=${appl}" \
  --data-urlencode "lvl=${lvl}" \
  --data-urlencode "reason=${reason}" \
  --data-urlencode "status=${status}" \
  --data-urlencode "repoId=${repo_id}" \
  --data-urlencode "branch=${branch}" \
  --data-urlencode "gpath=${gpath}" \
  --data-urlencode "gfile=${gfile}" \
  "${url}/object-requests"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
