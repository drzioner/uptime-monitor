#!/usr/bin/env bash
set -euo pipefail

SERVICES_FILE="$(dirname "$0")/services.json"
DEFAULT_TIMEOUT=10

# Resolve ${VAR} references with environment variable values
resolve_env() {
  local value="$1"
  while [[ "$value" =~ \$\{([a-zA-Z_][a-zA-Z0-9_]*)\} ]]; do
    local var_name="${BASH_REMATCH[1]}"
    local var_value="${!var_name:-}"
    if [[ -z "$var_value" ]]; then
      echo "WARNING: env var $var_name is not set" >&2
    fi
    value="${value/\$\{$var_name\}/$var_value}"
  done
  echo "$value"
}

ok=0
fail=0
total=$(jq length "$SERVICES_FILE")

for i in $(seq 0 $((total - 1))); do
  name=$(jq -r ".[$i].name" "$SERVICES_FILE")
  url=$(jq -r ".[$i].url" "$SERVICES_FILE")
  timeout=$(jq -r ".[$i].timeout // $DEFAULT_TIMEOUT" "$SERVICES_FILE")

  # Build curl header args from .headers object
  curl_headers=()
  headers_json=$(jq -r ".[$i].headers // empty" "$SERVICES_FILE")
  if [[ -n "$headers_json" ]]; then
    while IFS= read -r key; do
      raw_value=$(jq -r --arg k "$key" ".[$i].headers[\$k]" "$SERVICES_FILE")
      resolved_value=$(resolve_env "$raw_value")
      curl_headers+=(-H "$key: $resolved_value")
    done < <(jq -r ".[$i].headers | keys[]" "$SERVICES_FILE")
  fi

  printf "Pinging %s (%s) ... " "$name" "$url"

  response=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" --max-time "$timeout" "${curl_headers[@]+"${curl_headers[@]}"}" "$url" 2>/dev/null) || response="000 0"
  http_code="${response%% *}"
  time_total="${response##* }"

  if [[ "$http_code" =~ ^2 ]]; then
    echo "OK (status=$http_code, time=${time_total}s)"
    ((ok++))
  else
    echo "FAIL (status=$http_code, time=${time_total}s)"
    ((fail++))
  fi
done

echo ""
echo "--- Summary ---"
echo "Total: $total | OK: $ok | FAIL: $fail"

[[ $fail -eq 0 ]]
