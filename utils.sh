#!/bin/bash

#colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[31m'
BLINKRED="\033[31;5m"
NC='\033[0m'

# clone git repos
# set required env variables either locally or as global env variables
clone_repos() {
    curl --user "$GITHUB_USER:$GIT_TOKEN" "https://api.$GHE_SERVER/orgs/$ORG/repos?per_page=100/" | grep -o 'git@[^"]*' | xargs -L1 git clone
}

# prints Banner
display() {
    local message="$1"
    printf "\n\n${GREEN}"
    printf "======================================================================================================\n"
    printf "======================================================================================================\n"
    printf "======================================================================================================\n"
    printf "==                                                                                                  ==\n"
    printf "==                                                                                                  ==\n"
    printf "==                               ${YELLOW} ${message} ${NC} ${GREEN}                                  \n"
    printf "==                                                                                                  ==\n"
    printf "==                                                                                                  ==\n"
    printf "======================================================================================================\n"
    printf "======================================================================================================\n"
    printf "======================================================================================================\n"
    printf "${NC}\n\n"
}

# prints logs/errors
log() {
    if [ -z "${2:-}" ]; then
        printf "$(date) :${YELLOW} $1 ${NC}\n" # stdout
    else
        printf >&2 "$(date) :${RED} $1 : $2 ${NC}\n" # stderr
    fi
}

# check if a command/package exists
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

#check node version
check_node_ver() {
    node_version="$(cut -d'.' -f1 <<<"$(node -v)")"
    major_ver=${node_version:1}
    if [ "${major_ver:1}" -ge "14" ]; then
        true
    else
        false
    fi
}


# displays a progress bar to imitate loading
display_progress() {
    printf "${YELLOW}$1${NC}"
    echo -ne '>>>>>>>>>>>>>>            [50%]\r'
    sleep 0.3
    echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\n'
}

# check OSType
# OsType=$(uname -s)
# case $OsType in

# # MacOS
# Darwin*) ;;

# # Ubuntu
# Linux*) ;;

# # Windows
# CYGWIN* | MINGW32* | MSYS* | MINGW*) ;;
# esac
