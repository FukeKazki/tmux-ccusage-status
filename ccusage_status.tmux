#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

update_tmux_option() {
	local option="$1"
	local option_value
	local new_option_value

	option_value=$(tmux show-option -gqv "$option")
	new_option_value=$(echo "$option_value" | sed "s|#{ccusage_status}|#($CURRENT_DIR/scripts/status.sh)|g")
	tmux set-option -gq "$option" "$new_option_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}

main
