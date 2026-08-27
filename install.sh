#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
backup_suffix=$(date +%Y%m%d%H%M%S)

link_file() {
  source_path="$repo_dir/$1"
  target_path="$HOME/$2"
  target_dir=$(dirname -- "$target_path")

  mkdir -p "$target_dir"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    printf 'ok      %s\n' "$target_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_path="$target_path.backup-$backup_suffix"
    mv "$target_path" "$backup_path"
    printf 'backup  %s -> %s\n' "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
  printf 'linked  %s -> %s\n' "$target_path" "$source_path"
}

link_file zsh/.zshrc .zshrc
link_file git/.gitconfig .gitconfig
link_file git/.gitignore_global .gitignore_global
link_file claude/.claude/.gitignore .claude/.gitignore
link_file claude/.claude/CLAUDE.md .claude/CLAUDE.md
link_file claude/.claude/settings.json .claude/settings.json
link_file claude/.claude/statusline.sh .claude/statusline.sh
link_file claude/.claude/hooks/cb-desk.sh .claude/hooks/cb-desk.sh
link_file claude/.claude/skills/end/SKILL.md .claude/skills/end/SKILL.md
link_file claude/.claude/skills/merge-worktrees/SKILL.md .claude/skills/merge-worktrees/SKILL.md

