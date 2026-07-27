# tmux-ccusage-status

Show today's AI coding agent cost and current 5-hour session block usage in your tmux status line, powered by [ccusage](https://github.com/ryoppippi/ccusage).

```
$1.76 37%
```

- `$1.76` — total cost so far today, across all agents ccusage detects (Claude Code, Codex, Gemini CLI, Copilot CLI, etc.)
- `37%` — token usage of the current active 5-hour session block, relative to the largest block ccusage has seen historically (`ccusage blocks -t max`)

## Requirements

- [tmux](https://github.com/tmux/tmux) >= 1.9
- [ccusage](https://github.com/ryoppippi/ccusage) available on `$PATH`
- [jq](https://jqlang.org/)

## Installation

### With TPM (recommended)

Add this line to `~/.tmux.conf`:

```tmux
set -g @plugin 'FukeKazki/tmux-ccusage-status'
```

Then hit `prefix + I` to install.

### Manual

```sh
git clone https://github.com/FukeKazki/tmux-ccusage-status ~/.tmux/plugins/tmux-ccusage-status
```

Add this to `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-ccusage-status/ccusage_status.tmux
```

## Usage

Add the `#{ccusage_status}` placeholder anywhere in `status-left` or `status-right`:

```tmux
set -g status-right "#{ccusage_status} | %H:%M "
```

The plugin rewrites this placeholder into a `#()` shell command at load time, so it must be set **before** `run-shell`/TPM's `run '~/.tmux/plugins/tpm/tpm'` line is evaluated.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `@ccusage_status_cache_ttl` | `60` | Seconds to cache ccusage output. `ccusage` spawns a Node process, so a short-lived cache keeps a low `status-interval` from hammering it. |

```tmux
set -g @ccusage_status_cache_ttl 30
```

## Notes

- If `ccusage` isn't found on `$PATH` (common when tmux's process environment is trimmed down, e.g. via `set-environment -g PATH`), the status shows `ccusage:N/A`. Make sure the script's resolved `$PATH` includes wherever `ccusage` actually lives (mise/asdf/nvm shims, npm global bin, etc.) — see `scripts/status.sh`.
- The block-usage percentage is omitted when there's no active 5-hour block.

## License

MIT
