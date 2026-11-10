#!/usr/bin/env bash
# POST <api-url>/object-request
# usage: post-object-request.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --rsn <rsn> --repo <repo> --gpath <gpath> --gfile <gfile> --branch <branch> --proj <proj> --task <task> --stsk <stsk> --arfp <arfp> --rfp <rfp> --lock <lock>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: post-object-request.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --rsn <rsn> --repo <repo> --gpath <gpath> --gfile <gfile> --branch <branch> --proj <proj> --task <task> --stsk <stsk> --arfp <arfp> --rfp <rfp> --lock <lock>
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
lvl=""
rsn=""
repo=""
gpath=""
gfile=""
branch=""
proj=""
task=""
stsk=""
arfp=""
rfp=""
lock=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --lvl) lvl="${2:-}"; shift 2 ;;
    --rsn) rsn="${2:-}"; shift 2 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --gpath) gpath="${2:-}"; shift 2 ;;
    --gfile) gfile="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --proj) proj="${2:-}"; shift 2 ;;
    --task) task="${2:-}"; shift 2 ;;
    --stsk) stsk="${2:-}"; shift 2 ;;
    --arfp) arfp="${2:-}"; shift 2 ;;
    --rfp) rfp="${2:-}"; shift 2 ;;
    --lock) lock="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$appl" || -z "$lvl" || -z "$rsn" || -z "$repo" || -z "$gpath" || -z "$gfile" || -z "$branch" || -z "$proj" || -z "$task" || -z "$stsk" || -z "$arfp" || -z "$rfp" || -z "$lock" ]]; then
  usage
fi

if [[ -z "$token" ]]; then
  usage
fi

url="${url%/}"

payload="$(printf '{"url":"%s","token":"%s","appl":"%s","lvl":"%s","rsn":"%s","repo":"%s","gpath":"%s","gfile":"%s","branch":"%s","proj":"%s","task":"%s","stsk":"%s","arfp":"%s","rfp":"%s","lock":"%s"}' \
  "$(json_escape "$url")" \
  "$(json_escape "$token")" \
  "$(json_escape "$appl")" \
  "$(json_escape "$lvl")" \
  "$(json_escape "$rsn")" \
  "$(json_escape "$repo")" \
  "$(json_escape "$gpath")" \
  "$(json_escape "$gfile")" \
  "$(json_escape "$branch")" \
  "$(json_escape "$proj")" \
  "$(json_escape "$task")" \
  "$(json_escape "$stsk")" \
  "$(json_escape "$arfp")" \
  "$(json_escape "$rfp")" \
  "$(json_escape "$lock")")"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -X POST -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  --data "$payload" \
  "${url}/object-request"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
