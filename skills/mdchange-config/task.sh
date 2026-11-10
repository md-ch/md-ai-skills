#!/usr/bin/env bash
# GET <api-url>/task?proj=<proj>&task=<task>&subtask=<subtask>
# usage: task.sh --url <api-url> --token <api-token> --proj <proj> --task <task> --subtask <subtask>
#        task.sh --token <api-token> --env-file <path>
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: task.sh --url <api-url> --token <api-token> --proj <proj> --task <task> --subtask <subtask>
       task.sh --token <api-token> --env-file <path>
EOF
  exit 2
}

url=""
token=""
proj=""
task=""
subtask=""
env_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) url="${2:-}"; shift 2 ;;
    --token) token="${2:-}"; shift 2 ;;
    --proj) proj="${2:-}"; shift 2 ;;
    --task) task="${2:-}"; shift 2 ;;
    --subtask) subtask="${2:-}"; shift 2 ;;
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
  proj="${proj:-${MDCMS_PROJECT:-}}"
  task="${task:-${MDCMS_TASK:-}}"
  subtask="${subtask:-${MDCMS_SUBTASK:-}}"
fi

if [[ -z "$url" || -z "$token" || -z "$proj" || -z "$task" || -z "$subtask" ]]; then
  usage
fi

url="${url%/}"

hdr="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$hdr" "$body"' EXIT

curl -sS -G -D "$hdr" -o "$body" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/json" \
  --data-urlencode "proj=${proj}" \
  --data-urlencode "task=${task}" \
  --data-urlencode "subtask=${subtask}" \
  "${url}/task"

status="$(awk 'BEGIN{c=""} /^HTTP/{c=$2} END{print c}' "$hdr")"
printf 'HTTP_STATUS=%s\n' "$status"
cat "$body"
printf '\n'
