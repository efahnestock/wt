# wt - Git worktree management tool
# Source this file in your .bashrc

# Shell function wrapper for wt
# Handles cd operations that can't be done from the script itself
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
        # Capture output to handle special signals
        local output
        local exit_code
        output=$(command wt "$@" 2>&1)
        exit_code=$?

        # Filter out and handle special signals
        local cd_target=""
        local main_repo=""
        local removed_wt=""

        while IFS= read -r line; do
            case "$line" in
                __WT_CD__:*)
                    cd_target="${line#__WT_CD__:}"
                    ;;
                __WT_MAIN__:*)
                    main_repo="${line#__WT_MAIN__:}"
                    ;;
                __WT_REMOVED__:*)
                    removed_wt="${line#__WT_REMOVED__:}"
                    ;;
                *)
                    echo "$line"
                    ;;
            esac
        done <<< "$output"

        # Handle cd after new
        if [[ -n "$cd_target" ]] && [[ -d "$cd_target" ]]; then
            cd "$cd_target"
        fi

        # Handle cd after done (if we were in the removed worktree)
        if [[ -n "$removed_wt" ]] && [[ -n "$main_repo" ]]; then
            if [[ "$PWD" == "$removed_wt"* ]]; then
                echo "Returning to main repo..."
                cd "$main_repo"
            fi
        fi

        return $exit_code
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
        new)
            # Complete --no-cd flag
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--no-cd" -- "$cur"))
            fi
            ;;
        "")
            # Complete commands
            COMPREPLY=($(compgen -W "new ls done cd" -- "$cur"))
            ;;
    esac
}
complete -F _wt_completions wt
