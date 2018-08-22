#!/usr/bin/env bash
#===============================================================================
#
#          FILE: disk_usage.sh
# 
#   DESCRIPTION: Use this script in a Jenkins job to check Jenkins disk usage.
# 
#        AUTHOR: Elliott Indiran <eindiran@uchicago.edu>
#===============================================================================

set -o errexit  # Exit on a command failing
set -o errtrace # Exit when a function or subshell has an error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Return error code for first failed command in pipe

# Defaults
JENKINS_WORKSPACE_DIR=/var/lib/jenkins
BUILD_OUTPUT_DIR=/data

while [[ $# -gt 0 ]] ; do
    key="$1"
    case "$key" in
        --help|-h)
            printf "Usage: ./disk_usage.sh [-w <workspace path>] [-b <build path>]\n"
            exit 0
            ;;
        --workspace|-w)
            shift
            JENKINS_WORKSPACE_DIR="$1"
            ;;
        --build|-b)
            shift
            BUILD_OUTPUT_DIR="$1"
            ;;
        *)
            printf "Unknown argument: %s" "$key"
            ;;
    esac
    shift
done

function get_disk_usage_percentage() {
    # Get the disk usage as a percentage
    df "$1" | tail -n 1 | awk '{ sub(/%/, ""); print $5 }'
}

FAILED=false
declare -a disk_arr=("$JENKINS_WORKSPACE_DIR" "$BUILD_OUTPUT_DIR")

for disk in "${disk_arr[@]}"; do
    DISK_USAGE=$(get_disk_usage_percentage "$disk")
    if [[ "$DISK_USAGE" -gt 75 ]] ; then
        printf "High disk usage for disk %s: %d\n" "$disk" "$DISK_USAGE"
        FAILED=true
    else
        printf "Normal disk usage for disk %s: %d\n" "$disk" "$DISK_USAGE"
    fi
done

if [ "$FAILED" = true ] ; then
    echo "Please address disk usage problems."
    exit 1
else
    echo "No problems detected."
fi
