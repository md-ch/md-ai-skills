#!/usr/bin/env bash
# GET <api-url>/object-requests?appl=&lvl=&status=&reason=&objn=&objt=&ifsp=&ifsf=
# usage: get-object-requests.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> [--status <status>] [--reason <reason>] [--objn <objn>] [--objt <objt>] [--ifsp <ifsp>] [--ifsf <ifsf>]
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: get-object-requests.sh --url <api-url> --token <api-token> --appl <appl> --lvl <lvl> [--status <status>] [--reason <reason>] [--objn <objn>] [--objt <objt>] [--ifsp <ifsp>] [--ifsf <ifsf>]
EOF
  exit 2
}

url=""
token=""
appl=""
lvl=""
status="01"
reason=""
objn=""
objt=""
ifsp=""
ifsf=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --appl) appl="${2:-}"; shift 2 ;;
    --lvl) lvl="${2:-}"; shift 2 ;;
    --status) status="${2:-}"; shift 2 ;;
    --reason) reason="${2:-}"; shift 2 ;;
    --objn) objn="${2:-}"; shift 2 ;;
    --objt) objt="${2:-}"; shift 2 ;;
    --ifsp) ifsp="${2:-}"; shift 2 ;;
    --ifsf) ifsf="${2:-}"; shift 2 ;;
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

query_args=()
query_args+=(--data-urlencode "appl=${appl}")
query_args+=(--data-urlencode "lvl=${lvl}")
if [[ -n "$status" ]]; then
  query_args+=(--data-urlencode "status=${status}")
fi
if [[ -n "$reason" ]]; then
  query_args+=(--data-urlencode "reason=${reason}")
fi
if [[ -n "$objn" ]]; then
  query_args+=(--data-urlencode "objn=${objn}")
fi
if [[ -n "$objt" ]]; then
  query_args+=(--data-urlencode "objt=${objt}")
fi
if [[ -n "$ifsp" ]]; then
  query_args+=(--data-urlencode "ifsp=${ifsp}")
fi
if [[ -n "$ifsf" ]]; then
  query_args+=(--data-urlencode "ifsf=${ifsf}")
fi

MSYS2_ARG_CONV_EXCL='ifsp=' curl -sS --connect-timeout 10 --max-time 30 -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  "${query_args[@]}" \
  "${url}/object-requests"

status_code="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status_code"
cat "$body"
printf '\n'
