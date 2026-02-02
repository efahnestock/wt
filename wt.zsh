# wt - Git worktree management tool
# Source this file in your .zshrc

# Shell function wrapper for wt (needed for `wt cd` to change directory)
wt() {
    if [[ "$1" == "cd" ]]; then
        local target
        target=$(command wt path "${@:2}")
        if [[ -d "$target" ]]; then
            cd "$target"
        else
            echo "Worktree not found: $target" >&2
            return 1
        fi
    else
        command wt "$@"
    fi
}

# Zsh completion for wt
_wt() {
    local state

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            _values 'wt commands' \
                'new[Create worktree (uses existing branch if present)]' \
                'list[List all worktrees]' \
                'done[Remove worktree (fails if uncommitted/unpushed)]' \
                'cd[Change to worktree directory]'
            ;;
        args)
            case ${words[2]} in
                cd|done|rm|remove|path)
                    local branches=($(command wt __branches 2>/dev/null))
                    _values 'branches' $branches
                    ;;
            esac
            ;;
    esac
}
compdef _wt wt
