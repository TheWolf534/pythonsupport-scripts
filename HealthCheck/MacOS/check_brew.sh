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
    for brew_path in "${brew_paths[@]}" ; do
        echo
        if [ -x $brew_path ]; then
            map_set "healthCheckResults" "brew,installed" "true"
            brew_path=$(dirname $brew)
            break
        else
            map_set "healthCheckResults" "brew,installed" "false"
            return 0
        fi
    done

    map_set "healthCheckResults" "brew,version" "$(${brew_path} --version)"
    map_set "healthCheckResults" "brew,path" "$brew_path"

    if grep -q $brew_path $PATH; then
        map_set "healthCheckResults" "brew,in-path" "true"
    else
        map_set "healthCheckResults" "brew,in-path" "false"
    fi
}