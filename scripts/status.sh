#!/usr/bin/env bash
# Prints "$<today's cost> <active 5h block token usage>%" for use in tmux status line.
# Requires: ccusage (https://github.com/ryoppippi/ccusage), jq

set -u

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

# mise/asdf/nvm shims are commonly missing from tmux's process PATH.
export PATH="$HOME/.local/share/mise/shims:$PATH:/opt/homebrew/bin:/usr/local/bin"

cache_ttl=$(get_tmux_option "@ccusage_status_cache_ttl" "60")
cache_file="${TMPDIR:-/tmp}/tmux-ccusage-status.cache"

if [ -f "$cache_file" ]; then
  now=$(date +%s)
  mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -lt "$cache_ttl" ]; then
    cat "$cache_file"
    exit 0
  fi
fi

if ! command -v ccusage >/dev/null 2>&1; then
  echo "ccusage:N/A"
  exit 0
fi

today=$(date +%Y-%m-%d)

daily_cost=$(ccusage daily -j --since "$today" --until "$today" 2>/dev/null \
  | jq -r '[.daily[]?.totalCost] | add // 0')

block_percent=$(ccusage blocks -j -t max 2>/dev/null \
  | jq -r '[.blocks[] | select(.isActive == true)][0].tokenLimitStatus.percentUsed // empty')

cost_fmt=$(printf '$%.2f' "${daily_cost:-0}")

if [ -n "$block_percent" ]; then
  output="${cost_fmt} $(printf '%.0f%%' "$block_percent")"
else
  output="$cost_fmt"
fi

echo "$output" | tee "$cache_file" >/dev/null
