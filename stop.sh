#!/bin/bash

source ./utils.sh

KILL_SIG="$1"

stop() {
    OsType=$(uname -s)
    if [ $OsType == "Darwin" ] || [ $OsType == "Linux" ]; then
        nohup kill -9 $(lsof -t -i:4200) $(lsof -t -i:3001) >/dev/null 2>&1
    else
        taskkill //f //im node.exe >/dev/null 2>&1
    fi
}

prompt_stop() {
    read -r -p $'\nThis will terminate the demo application if running. You will have to run it again. Are you sure you want continue? Press (Y)es/(N)o : ' ch
    if [ "$ch" == "Y" ] || [ "$ch" == "y" ]; then
        stop
        log "${GREEN} Application terminated successfully. ${NC}"
    elif [ "$ch" == "N" ] || [ "$ch" == "n" ]; then
        log "Process aborted"
    else
        log ERROR "Invalid selection"
    fi
}
if [ "${KILL_SIG}" == true ]; then
    stop
else
    prompt_stop
fi
