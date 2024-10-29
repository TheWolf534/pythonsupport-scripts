#!/bin/bash


brew_paths=(
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
)

which_brew=$(which brew 2>/dev/null)
if [ $? -eq 0 ]; then
    brew_paths+=($which_brew)
fi

check_brew() {
    local brew
    for brew in "${brew_paths[@]}" ; do
        if [ -x $brew ]; then
            map_set "healthcheck" "brew,installed" "true"
            brew_path=$(dirname $brew)
        else
            map_set "healthcheck" "brew,installed" "false"
            return 0
        fi
    done

    map_set "healthcheck" "brew,version" "$(${brew_path} --version)"
    map_set "healthcheck" "brew,path" "$brew_path"

    if grep -q $brew_path $PATH; then
        map_set "healthcheck" "brew,in-path" "true"
    else
        map_set "healthcheck" "brew,in-path" "false"
    fi
}