#!/bin/bash

# checks for environmental variables for remote and branch 
if [ -z "$REMOTE_PS" ]; then
  REMOTE_PS="TheWolf534/pythonsupport-scripts"
fi
if [ -z "$BRANCH_PS" ]; then
  BRANCH_PS="main"
fi

url_ps="https://raw.githubusercontent.com/$REMOTE_PS/$BRANCH_PS/HealthCheck/MacOS"

source <(curl -s $url_ps/output.sh)
source <(curl -s $url_ps/check_python.sh)
source <(curl -s $url_ps/check_vsCode.sh)
source <(curl -s $url_ps/check_firstYearPackages.sh)
source <(curl -s $url_ps/map.sh)


# Function to clean up resources and exit
cleanup() {
    echo -e "\nCleaning up and exiting..."
    # Kill the non_verbose_output process if it's still running
    if [ ! -z "$output_pid" ]; then
        kill $output_pid 2>/dev/null
    fi

    tput cnorm
    #map_cleanup "healthCheckResults"
    release_lock "healthCheckResults"
    
    exit 1
}

# Set up the trap for SIGINT (Ctrl+C)
trap cleanup SIGINT

main() {
    create_banner

    # Initialize the health check results map
    map_set "healthCheckResults" "python3,name" "Python"
    map_set "healthCheckResults" "conda,name" "Conda"
    map_set "healthCheckResults" "code,name" "Visual Studio Code"
    map_set "healthCheckResults" "ms-python.python,name" "Python Extension"
    map_set "healthCheckResults" "ms-toolsai.jupyter,name" "Jupyter Extension"
    map_set "healthCheckResults" "numpy,name" "Numpy"
    map_set "healthCheckResults" "dtumathtools,name" "DTU Math Tools"
    map_set "healthCheckResults" "pandas,name" "Pandas"
    map_set "healthCheckResults" "scipy,name" "Scipy"
    map_set "healthCheckResults" "statsmodels,name" "Statsmodels"
    map_set "healthCheckResults" "uncertainties,name" "Uncertainties"

    

    
    if [[ "$1" == "--verbose" || "$1" == "-v" ]]; then
    :
    else
    non_verbose_output &
    fi
    output_pid=$!

    # Run checks sequentially
    check_python
    check_vsCode
    check_firstYearPackages

    verbose_output

    # Wait for the checks to finish being output
    wait

    cleanup
}

# Main execution
main $1