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

# Function to create a section header
print_section_header() {
    local title=$1
    local width=80  # Wider than non-verbose for more detail
    echo
    echo -e "\e[1;34m═══ $title ══$(printf '═%.0s' $(seq $((width - ${#title} - 8))))\e[0m"
}

# Function to print a labeled value with optional color
print_info() {
    local label=$1
    local value=$2
    local pad_length=25  # Adjust this for alignment
    printf "\e[1;36m%-${pad_length}s\e[0m %s\n" "$label:" "$value"
}

# Function to print installation status with color
print_install_status() {
    local status=$1
    if [ "$status" = "true" ]; then
        echo -e "\e[1;32mINSTALLED\e[0m"
    else
        echo -e "\e[1;31mNOT INSTALLED\e[0m"
    fi
}

verbose_output() {
    clear
    create_banner
    
    # Programs Section
    print_section_header "System Programs"
    
    # Python Information
    echo -e "\n\e[1;33mPython Information:\e[0m"
    print_info "Name" "$(map_get "healthCheckResults" "python3,name")"
    print_info "Installation Status" "$(print_install_status "$(map_get "healthCheckResults" "python3,installed")")"
    print_info "Paths" "$(map_get "healthCheckResults" "python3,paths")"
    print_info "Versions" "$(map_get "healthCheckResults" "python3,versions")"
    
    # Conda Information
    echo -e "\n\e[1;33mConda Information:\e[0m"
    print_info "Name" "$(map_get "healthCheckResults" "conda,name")"
    print_info "Installation Status" "$(print_install_status "$(map_get "healthCheckResults" "conda,installed")")"
    print_info "Paths" "$(map_get "healthCheckResults" "conda,paths")"
    print_info "Versions" "$(map_get "healthCheckResults" "conda,versions")"
    print_info "Python Path" "$(map_get "healthCheckResults" "conda,python_path")"
    print_info "Python Version" "$(map_get "healthCheckResults" "conda,python_version")"
    
    # VSCode Information
    echo -e "\n\e[1;33mVSCode Information:\e[0m"
    print_info "Name" "$(map_get "healthCheckResults" "code,name")"
    print_info "Installation Status" "$(print_install_status "$(map_get "healthCheckResults" "code,installed")")"
    print_info "Path" "$(map_get "healthCheckResults" "code,path")"
    print_info "Version" "$(map_get "healthCheckResults" "code,version")"

    # Extensions Section
    print_section_header "VSCode Extensions"
    
    for ext in "${extension_requirements[@]}"; do
        echo -e "\n\e[1;33m$(map_get "healthCheckResults" "${ext},name"):\e[0m"
        print_info "Installation Status" "$(print_install_status "$(map_get "healthCheckResults" "${ext},installed")")"
        print_info "Version" "$(map_get "healthCheckResults" "${ext},version")"
    done

    # Python Packages Section
    print_section_header "Python Packages"
    
    for package in "${package_requirements[@]}"; do
        echo -e "\n\e[1;33m$(map_get "healthCheckResults" "${package},name"):\e[0m"
        print_info "Installation Status" "$(print_install_status "$(map_get "healthCheckResults" "${package},installed")")"
        print_info "Source" "$(map_get "healthCheckResults" "${package},source")"
        print_info "Path" "$(map_get "healthCheckResults" "${package},path")"
        print_info "Version" "$(map_get "healthCheckResults" "${package},version")"
    done
    
    echo -e "\n\e[1;34m$(printf '═%.0s' $(seq 80))\e[0m"
}