# wt - Git worktree management tool
# Source this file in your .bashrc

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

# Tab completion for wt
_wt_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cmd="${COMP_WORDS[1]}"

    case "$cmd" in
        cd|done|rm|remove|path)
            # Complete with branch names
            local branches=$(command wt __branches 2>/dev/null)
            COMPREPLY=($(compgen -W "$branches" -- "$cur"))
            ;;
        "")
            # Complete commands
            COMPREPLY=($(compgen -W "new list done cd" -- "$cur"))
            ;;
    esac
}
complete -F _wt_completions wt
