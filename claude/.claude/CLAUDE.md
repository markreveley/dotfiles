# Global Instructions

## Google Workspace CLI (`gws`)
- Installed globally via `npm install -g @googleworkspace/cli` (v0.5.0, requires Node 22 via fnm)
- Auth credentials: `~/.config/gws/credentials.enc` (encrypted, for `dirtwiretouring@gmail.com`)
- Client config: `~/.config/gws/client_secret.json` (OAuth desktop client from `dirtwire-touring-gws` GCP project)
- GCP project: `dirtwire-touring-gws` (owner account is `dirtwiretouring@gmail.com`, also listed as test user on the consent screen)
- Scopes: `gmail.modify` + `spreadsheets` + `drive` + `calendar` + `tasks`
- Safety: `gmail.modify` scope blocks deletes at API level (confirmed). Sends almost certainly blocked too (requires `gmail.send` scope). Do NOT skip permissions.
- **CLI flag:** Request bodies use `--json`, NOT `--body`. The `--body` flag does not exist.
- **`drive about get` requires `fields`** — pass via `--params '{"fields":"user,storageQuota"}'`. The CLI has no `--fields` flag.
- **CLI only - no MCP.** Google removed MCP server mode from `gws` entirely (2026-03-20, [PR #275](https://github.com/googleworkspace/cli/pull/275)). Discovery API generates hundreds of methods which overwhelmed MCP's context window - 7 bug fixes needed during its brief existence. Use the CLI directly via bash: `/opt/homebrew/bin/fnm exec --using=22 gws <service> <command>`. The stale `mcpServers.gws` entry in `~/.claude.json` was removed on 2026-05-14 (`claude mcp remove gws`).
- To re-auth: `gws auth login --account dirtwiretouring@gmail.com --scopes https://www.googleapis.com/auth/gmail.modify,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/tasks` then `cp ~/.config/gws/credentials.ZGlydHdpcmV0b3VyaW5nQGdtYWlsLmNvbQ.enc ~/.config/gws/credentials.enc` (CLI only finds default path).
- **Do NOT use `-s` for re-auth.** The `-s` flag opens an interactive scope picker where selecting `gmail.metadata` alongside `gmail.modify` contaminates the token - Gmail API enforces metadata-only restrictions on `messages.get` even with `gmail.modify` present. Use `--scopes` with full URLs to bypass the picker. (a294)
- **Status (2026-05-14):** CLI-only. Gmail, Sheets, Drive, Calendar, and Tasks all working under the `dirtwire-touring-gws` consent screen. Old `gmail-mcp-488105` project is fully detached and can be deleted.

## Gmail API Search Pitfalls
SSOT: assertions a267, a268, a269 in `org/assertions/assertions.json`. Skills reference these by ID.
- **`q` parameter silently fails under `gmail.metadata` scope.** (2026-03-20, source: [Gmail API filtering guide](https://developers.google.com/gmail/api/guides/filtering)) Returns no filtering instead of an error. Requires `gmail.readonly` or `gmail.modify` for queries to work. Our `gmail.modify` scope is fine.

## MCP Server Configuration — Known Pitfalls
**This mistake has been made in the wild — do not repeat it.**

- **`~/.claude/settings.json` `mcpServers` does NOT work.** Claude Code reads it but silently ignores it. No errors, no warnings. Servers configured here will never spawn.
- **`~/.claude.json` `mcpServers` is the real registry.** Only servers here get spawned. Use `claude mcp add` to register, `claude mcp list` to verify, `claude mcp remove` to delete.
- **Always verify with `claude mcp list`.** If a server doesn't appear there, it won't connect regardless of what's in config files.
- **Child processes get a minimal PATH.** `/opt/homebrew/bin` is not included. Reference tools like `fnm` by absolute path: `/opt/homebrew/bin/fnm`.
- **MCP servers only connect at Claude Code startup.** Adding or changing a server mid-session requires a restart.

## Shell Commands
- Always translate and explain the reasoning for all shell commands
- Show what the command does in plain English
- Explain why that specific command is needed for the task
- Always confirm with the user before running `rm` or any destructive file operation

## Shell Scripts
- Always run `shellcheck` on bash scripts before finishing

## Communication Style
- Be concise - short responses preferred
- JSON over YAML when there's a choice
- DRY matters - avoid duplication
- Never comment qualitatively on the user's questions or thoughts (e.g. "good question", "great idea") unless asked
- No throat-clearing or validation preamble before answering (e.g. "These are all important questions", "You're right to push back", "You're identifying something real"). Just answer.
