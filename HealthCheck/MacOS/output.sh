# Requirements arrays remain unchanged
program_requirements=(
    "python3"
    "conda"
    "code"
)
extension_requirements=(
    "ms-python.python"
    "ms-toolsai.jupyter"
)
package_requirements=(
    "numpy"
    "dtumathtools"
    "pandas"
    "scipy"
    "statsmodels"
    "uncertainties"
)
width=60

# Create a colorful banner - unchanged
create_banner() {
    clear
    local text="Welcome to the Python Support Health Check"
    local text_length=${#text}
    local padding=$(( ($width - $text_length - 2) / 2 ))
    local left_padding=$(printf "%*s" $padding)
    local right_padding=$(printf "%*s" $padding)
    local top_bottom_side=$(printf "%*s" $((padding * 2 + 2 + text_length)) | tr ' ' '*')
    local inside_box_width=$(printf "%*s" $((padding * 2 + text_length)))
    echo -e "\e[1;34m"
    echo "$top_bottom_side"
    echo "*$inside_box_width*"
    echo -e "*\e[1;32m$left_padding$text$right_padding\e[1;34m*"
    echo "*$inside_box_width*"
    echo "$top_bottom_side"
    echo -e "\e[0m"
}

# Update status function - unchanged
# Update status function - fixed
update_status() {
    local line=$1    # Removed *asterisks*
    local column=$2  # Removed *asterisks*
    local status_string=$3  # Removed *asterisks*
    tput cup $((line+8)) $column
    tput el
    echo "$status_string"
}

# Install status function - fixed
install_status() {
    local install_status=$1  # Removed *asterisks* and added local
    if [ "$install_status" = "true" ]; then
        status_string="INSTALLED"
        color_code="\e[1;42m"
    elif [ "$install_status" = "false" ]; then
        status_string="NOT INSTALLED"
        color_code="\e[1;41m"
    else
        status_string="STILL CHECKING"
        color_code="\e[1;43m"
    fi
    reset_color="\e[0m"
    echo -e "$color_code$status_string$reset_color"
}

# Non-verbose output function remains the same
non_verbose_output() {
    tput civis
    requirements=( "${program_requirements[@]}" "${extension_requirements[@]}" "${package_requirements[@]}")
    
    # First loop: Display initial status for all requirements
    for i in ${!requirements[@]}; do
        name=$(map_get "healthCheckResults" "${requirements[$i]},name")
        installed=$(map_get "healthCheckResults" "${requirements[$i]},installed")
        status_string=$(install_status "${installed:-}")
        clean_string=$(echo -e "$status_string" | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g')
        
        update_status $i 0 "$name"
        update_status $i $(($width - ${#clean_string})) "$status_string"
    done

    # Second loop: Wait for and update installation status
    for i in ${!requirements[@]}; do
        while true; do
            installed=$(map_get "healthCheckResults" "${requirements[$i]},installed")
            if [[ ! -z "$installed" ]]; then
                break
            fi
            # Sleep for a short period to avoid reading too frequently
            sleep 0.1
        done
        
        status_string=$(install_status "$installed")
        clean_string=$(echo -e "$status_string" | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g')
        update_status $i $(($width - 14)) ""
        update_status $i $(($width - ${#clean_string})) "$status_string"
    done
    
    tput cnorm  # Restore cursor
}