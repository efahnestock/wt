# wt - Git Worktree Management

A simple CLI tool for managing git worktrees with safety checks and Claude Code integration.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/efahnestock/wt/main/install.sh | bash
```

## Manual Install

```bash
git clone https://github.com/efahnestock/wt.git
cd wt
./install.sh
```

## Usage

```bash
# Create a new worktree with a new branch
wt new feature-auth
# Creates ../myrepo-feature-auth/ with branch feature-auth

# Create from a specific base
wt new hotfix-bug main

# Use an existing branch
wt new existing-branch
# Creates worktree for the existing branch

# List all worktrees with status
wt list
# /home/user/code/myrepo              [main]           ✓
# /home/user/code/myrepo-feature-auth [feature-auth]   *↑

# Change to a worktree directory
wt cd feature-auth

# Remove a worktree (with safety checks)
wt done feature-auth
# ERROR: Worktree 'feature-auth' has uncommitted changes
#   Commit or stash changes before removing

# Remove all safe worktrees
wt done --all
```

## Status Indicators

| Symbol | Meaning |
|--------|---------|
| ✓ | Clean - safe to remove |
| * | Uncommitted changes |
| ↑ | Unpushed commits |

## Features

### Safety Checks

`wt done` prevents accidental data loss by refusing to remove worktrees with:
- Uncommitted changes (staged or unstaged)
- Untracked files
- Unpushed commits

### Claude Code Integration

When creating worktrees, `wt` automatically:
- Symlinks `.claude/` to the main repo (shares settings like `CLAUDE.md`)
- Symlinks `~/.claude/projects/<worktree>` to the main repo's project dir (shares conversation history)

### Optional setup.sh

If your repo has an executable `setup.sh` in the root, it runs automatically when creating a worktree. Useful for:
- Installing dependencies
- Setting up pre-commit hooks
- Configuring environment

### Works From Any Subdirectory

Run `wt` from anywhere inside a git repo or worktree - it automatically finds the main repository.

## How It Works

Worktrees are created as siblings to the main repo:

```
~/code/
├── myrepo/                    # Main repository
│   ├── .git/                  # Git directory
│   └── .claude/               # Claude settings
├── myrepo-feature-auth/       # Worktree
│   ├── .git                   # File pointing to main .git
│   └── .claude -> ../myrepo/.claude
└── myrepo-bugfix/             # Another worktree
    ├── .git
    └── .claude -> ../myrepo/.claude
```

## Requirements

- Git 2.15+ (for worktree support)
- Bash 4+ or Zsh

## Shell Integration

The installer adds a shell function to handle `wt cd` (which needs to change your shell's directory). Tab completion is included for both Bash and Zsh.

## License

MIT
