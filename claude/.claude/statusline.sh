#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Get directory name (basename of current path)
dir_name=$(basename "$current_dir")

# Get git information if in a git repo
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    
    # Get git status with simplified flags to avoid locks
    git_status=""
    if ! git diff --quiet 2>/dev/null; then
        git_status="*"
    fi
    if ! git diff --cached --quiet 2>/dev/null; then
        git_status="${git_status}+"
    fi
    
    git_info=" (${branch}${git_status})"
fi

# Format and output the status line
printf "%s%s | %s" "$dir_name" "$git_info" "$model_name"