#!/bin/bash

brew_paths=(
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
)

check_brew() {
    for brew in "${brew_path[@]}" ; do
        if [ -x $brew ]; then
            map_set "healthcheck" "brew,installed" "true"
            brew_path="$brew"
        else
            map_set "healthcheck" "brew,installed" "false"
            return 0
        fi
    done

    map_set "healthcheck" "brew,version" "$(${brew_path} --version)"
    map_set "healthcheck" "brew,path" "$brew_path"

    if grep -q ${brew_path[@]} $PATH; then
        map_set "healthcheck" "brew,in-path" "true"
    else
        map_set "healthcheck" "brew,in-path" "false"
    fi
}