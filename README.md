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
- **Shared settings**: Symlinks `.claude/` to the main repo so `CLAUDE.md` and other settings are available in all worktrees
- **Shared conversations**: Symlinks `~/.claude/projects/<worktree>` to the main repo's project directory so conversation history is shared across all worktrees

When removing worktrees with `wt done`, these symlinks are cleaned up automatically.

#### Setup

Add `.claude` to your `.gitignore` (project or global):

```bash
# Project .gitignore
echo ".claude" >> .gitignore

# Or global gitignore
echo ".claude" >> ~/.gitignore
git config --global core.excludesfile ~/.gitignore
```

#### Suggested CLAUDE.md Addition

Add this to your project's `CLAUDE.md` or `~/.claude/CLAUDE.md` to inform Claude about worktree usage:

```markdown
## Worktree Management

This user uses git worktrees for feature development. A `wt` tool manages them:

- `wt new <branch> [base]` - Create worktree at `../repo-branch/`
- `wt list` - Show all worktrees with status (✓=clean, *=uncommitted, ↑=unpushed)
- `wt done <branch>` - Remove worktree (fails if uncommitted/unpushed changes)
- `wt done --all` - Remove all safe worktrees
- `wt cd <branch>` - Change directory to worktree (with tab completion)

Worktrees share settings and conversation history with the main repo via symlinks:
- `.claude/` → main repo's `.claude/` (for settings)
- `~/.claude/projects/<worktree-path>` → main repo's project dir (for conversations)

When suggesting the user work on a new feature, recommend using `wt new feature-name` to create an isolated worktree.
```

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
