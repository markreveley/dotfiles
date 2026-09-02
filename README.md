# dotfiles

Personal shell, Git, Neovim, and Claude Code configuration.

The repository uses a conventional package layout mirroring paths beneath `$HOME`:

- `zsh/` — Zsh configuration and aliases
- `git/` — Git configuration and global ignores
- `nvim/` — Neovim configuration and pinned plugin revisions
- `claude/` — hand-maintained Claude Code configuration, hooks, and skills

Claude runtime data, transcripts, caches, local overrides, and credentials are not
tracked. The installer links individual maintained files so runtime content can
continue to live in `~/.claude`.

## Install

```sh
git clone git@github.com:markreveley/dotfiles.git ~/dev/repos/public/dotfiles
~/dev/repos/public/dotfiles/install.sh
```

Existing destination files are preserved with a timestamped `.backup-*` suffix.
The script is safe to rerun.

Keep secrets and machine-local shell configuration in `~/.zshrc.local`; it is
sourced by the tracked `.zshrc` and intentionally remains outside this repository.
