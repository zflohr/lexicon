#!/usr/bin/env bash

declare -Ar GIT_REPO_TO_SOURCE_DIR_MAP=(
    ["${HOME}/github/bootstraps/"]="shell-scripts/bootstraps/"
    ["${HOME}/github/git-hooks/$(basename $(pwd))/"]="shell-scripts/git-hooks/"
)

print_commit_progress() {
    local progress_msg
    case "${1}" in
        'add')
            progress_msg="\nAdding the following files to the staging index:"
        ;;
        'commit')
            progress_msg="\nCreating a new commit..."
        ;;
        'rm')
            progress_msg="\nRemoving the following files
                from the staging index and the working tree:"
        ;;
    esac
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 6 2> /dev/null   # Set foreground color to cyan
        echo -e ${progress_msg}
        tput sgr0 2> /dev/null      # Turn off all attributes
    } || echo -e ${progress_msg}
}

print_filesystem_location() {
    local location="\nIn ${1}"
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 11 2> /dev/null   # Set foreground color to gold
        echo -e ${location}
        tput sgr0 2> /dev/null      # Turn off all attributes
    } || echo -e ${location}
}

update_external_git_repo() {
    if (( ${#added[*]} || ${#modified[*]} || ${#deleted[*]} )); then
        local -r COMMIT_MESSAGE=$(git log --pretty=format:"%B" -1 HEAD)
        (( ${#added[*]} || ${#modified[*]} )) &&
            cp ${added[*]} ${modified[*]} ${1}
        cd ${1}; print_filesystem_location "${1}"
        (( ${#added[*]} || ${#modified[*]} )) &&
            print_commit_progress "add" &&
            git add -v \
                $(basename -a ${added[*]} ${modified[*]} | paste -s -d ' ')
        (( ${#deleted[*]} )) &&
            print_commit_progress "rm" "${deleted[*]}" &&
            git rm $(basename -a ${deleted[*]} | paste -s -d ' ')
        print_commit_progress "commit"
        git commit -m "${COMMIT_MESSAGE}"
        cd - > /dev/null
    fi
}

get_diff_output() {
    [ -d ${1} ] && [ -d ${GIT_REPO_TO_SOURCE_DIR_MAP["${1}"]} ] || return 0
    local -a diff_statuses=($(git show --no-renames --name-status \
        --pretty=format:"%N" HEAD -- ${GIT_REPO_TO_SOURCE_DIR_MAP["${1}"]}))
    local -a added=() deleted=() modified=()
    for (( i=0; ${#diff_statuses[*]} - i; i+=2 )); do
        case "${diff_statuses[i]}" in
            'A')
                added+=(${diff_statuses[i + 1]})
            ;;
            'D')
                deleted+=(${diff_statuses[i + 1]})
            ;;
            'M')
                modified+=(${diff_statuses[i + 1]})
            ;;
        esac
    done
    update_external_git_repo ${1}
}

main() {
    for git_repo in "${!GIT_REPO_TO_SOURCE_DIR_MAP[@]}"; do
        get_diff_output "${git_repo}"
    done
    print_filesystem_location "$(pwd)/"
}

main