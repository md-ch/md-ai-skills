#!/usr/bin/env bash
# POST <api-url>/object-request
# usage: post-object-request.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --rsn <rsn> --proj <proj> --task <task> --stsk <stsk> --arfp <arfp> --rfp <rfp> --lock <lock> [--objn <objn> --objt <objt> --attr <attr> --fsfl <fsfl> --fsmb <fsmb>] [--ifsp <ifsp> --ifsf <ifsf>]
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: post-object-request.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> --rsn <rsn> --proj <proj> --task <task> --stsk <stsk> --arfp <arfp> --rfp <rfp> --lock <lock> [--objn <objn> --objt <objt> --attr <attr> --fsfl <fsfl> --fsmb <fsmb>] [--ifsp <ifsp> --ifsf <ifsf>]
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
proj=""
task=""
stsk=""
arfp=""
rfp=""
lock=""
objn=""
objt=""
attr=""
fsfl=""
fsmb=""
ifsp=""
ifsf=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --lvl) lvl="${2:-}"; shift 2 ;;
    --rsn) rsn="${2:-}"; shift 2 ;;
    --proj) proj="${2:-}"; shift 2 ;;
    --task) task="${2:-}"; shift 2 ;;
    --stsk) stsk="${2:-}"; shift 2 ;;
    --arfp) arfp="${2:-}"; shift 2 ;;
    --rfp) rfp="${2:-}"; shift 2 ;;
    --lock) lock="${2:-}"; shift 2 ;;
    --objn) objn="${2:-}"; shift 2 ;;
    --objt) objt="${2:-}"; shift 2 ;;
    --attr) attr="${2:-}"; shift 2 ;;
    --fsfl) fsfl="${2:-}"; shift 2 ;;
    --fsmb) fsmb="${2:-}"; shift 2 ;;
    --ifsp) ifsp="${2:-}"; shift 2 ;;
    --ifsf) ifsf="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "$url" || -z "$token" || -z "$appl" || -z "$lvl" || -z "$rsn" || -z "$proj" || -z "$task" || -z "$stsk" || -z "$arfp" || -z "$rfp" || -z "$lock" ]]; then
  usage
fi

if [[ -z "$objn" && -z "$ifsp" ]]; then
  usage
fi

url="${url%/}"

# Build JSON payload
payload="{"
payload+="\"appl\":\"$(json_escape "$appl")\","
payload+="\"lvl\":\"$(json_escape "$lvl")\","
payload+="\"rsn\":\"$(json_escape "$rsn")\","
payload+="\"proj\":\"$(json_escape "$proj")\","
payload+="\"task\":\"$(json_escape "$task")\","
payload+="\"stsk\":\"$(json_escape "$stsk")\","
payload+="\"arfp\":\"$(json_escape "$arfp")\","
payload+="\"rfp\":\"$(json_escape "$rfp")\","
payload+="\"lock\":\"$(json_escape "$lock")\""

if [[ -n "$objn" ]]; then
  payload+=",\"objn\":\"$(json_escape "$objn")\""
fi
if [[ -n "$objt" ]]; then
  payload+=",\"objt\":\"$(json_escape "$objt")\""
fi
if [[ -n "$attr" ]]; then
  payload+=",\"attr\":\"$(json_escape "$attr")\""
fi
if [[ -n "$fsfl" ]]; then
  payload+=",\"fsfl\":\"$(json_escape "$fsfl")\""
fi
if [[ -n "$fsmb" ]]; then
  payload+=",\"fsmb\":\"$(json_escape "$fsmb")\""
fi
if [[ -n "$ifsp" ]]; then
  payload+=",\"ifsp\":\"$(json_escape "$ifsp")\""
fi
if [[ -n "$ifsf" ]]; then
  payload+=",\"ifsf\":\"$(json_escape "$ifsf")\""
fi

payload+="}"

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
