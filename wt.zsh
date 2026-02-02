# wt - Git worktree management tool
# Source this file in your .zshrc

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

# Zsh completion for wt
_wt() {
    local state

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            _values 'wt commands' \
                'new[Create worktree and cd into it]' \
                'ls[List all worktrees with status]' \
                'done[Remove worktree (fails if uncommitted/unpushed)]' \
                'cd[Change to worktree directory]'
            ;;
        args)
            case ${words[2]} in
                cd|done|rm|remove|path)
                    local branches=($(command wt __branches 2>/dev/null))
                    _values 'branches' $branches
                    ;;
                new)
                    _arguments '--no-cd[Do not cd into new worktree]'
                    ;;
            esac
            ;;
    esac
}
compdef _wt wt
