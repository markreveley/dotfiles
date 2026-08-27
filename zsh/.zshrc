export PATH="/Users/mark/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/mark/.antigravity/antigravity/bin:$PATH"

# Claude Code with dangerously-skip-permissions flag
alias clauded="claude --dangerously-skip-permissions"

# Secrets (API keys, etc.) — kept out of version control
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

alias dev='cd /Users/mark/dev'

# agen - Unix-native AI agent CLI
export PATH="/Users/mark/dev/repos/mine/AGEN/agen:$PATH"
export PATH="/Users/mark/dev/repos/mine/AGEN/agen-skills:$PATH"

# shell - natural language to shell command (stages in prompt, doesn't execute)
shell() {
  print -z "$(agen "Convert to a shell command. Output ONLY the raw command. No markdown, no code blocks, no explanation, no backticks. Just the command itself: $*")"
}
# fnm (Fast Node Manager)
eval "$(fnm env)"

alias n='nvim'
export PATH="$PATH:/Users/mark/dev/repos/mine/SHELL-AGENTICS/agen"

alias advance="mix tourlab.list advance"
alias todos="mix tourlab.todos"
alias flights="mix run -e 'Tourlab.Table.t(:flights)'"
alias transpo="mix run -e 'Tourlab.Table.t(:travel)'"
alias hotels="mix run -e 'Tourlab.Table.t(:hotels)'"

export PATH="$HOME/dev/repos/mine/DIRTWIRE/bandlab-data-dirtwire/bin:$PATH"
export PATH="$HOME/bin:$PATH"

alias cc="claude --dangerously-skip-permissions"
alias cx="codex --approve-for-me"

# Send view("MMDD") to the display surface in cmux
# Usage: d 0318
unalias d 2>/dev/null
d() { mix tourlab.view "$@"; }

# Fuzzy find a file and render with glow
gf() { fzf --preview 'glow {}' | xargs glow; }

# Fuzzy find a file and open in neovim
nf() { fzf --preview 'cat {}' | xargs nvim; }
eval "$(direnv hook zsh)"
eval "$(direnv hook zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
