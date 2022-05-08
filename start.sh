#!/bin/bash

source ./stop.sh true
source ./utils.sh

NODEJS_WIN_INSTALLER="https://nodejs.org/dist/v16.13.1/node-v16.13.1-x86.msi"

abort() {
    log ERROR "You chose to kill the setup, aborting.."
    log "Done. BYE"
    exit 1
}

display "Demo Application"

printf "Select an application from the following \n"
printf "${YELLOW}"
printf "1. Public \n"
printf "2. Health Care \n"
printf "3. Distribution \n"
printf "${NC}"
read -r -p "Your selection - " option
if [ $option == "1" ]; then
    APP_NAME="public"
elif [ $option == "2" ]; then
    APP_NAME="healthcare"
elif [ $option == "3" ]; then
    APP_NAME="distribution"
else
    log ERROR "Invalid selection"
    exit 1
fi

SERVER="${APP_NAME}-server"
UI="${APP_NAME}-ui"

if ! [ -d $SERVER ]; then
    SERVER="${APP_NAME}-server-main"
fi

if ! [ -d $UI ]; then
    UI="${APP_NAME}-ui-main"
fi

#upgrade node
upgrade_node() {
    local OSTYPE="$1"
    log "Node already installed. Version : $(echo $(node -v))"
    if ! check_node_ver; then
        read -r -p "The application requires v14 or above. This will update node to the latest version? Are you sure you want continue? Press (Y)es/(N)o : " ch1
        if [ "$ch1" == "Y" ] || [ "$ch1" == "y" ]; then
            display "Updating nodejs"
            if [ $OSTYPE == "Linux" ]; then
                sudo npm cache clean -f 2>/dev/null
                sudo npm install n 2>/dev/null
                sudo n stable 2>/dev/null
            elif [ $OSTYPE == 'Darwin' ]; then
                sudo brew cache clean -f 2>/dev/null
                sudo brew install n 2>/dev/null
                sudo n stable 2>/dev/null
            else
                log "Use this link to download and update nodejs" "${NODEJS_WIN_INSTALLER}"
            fi
        else
            abort
        fi
    fi
}

run_application() {
    cd ..
    if ! [ -d $SERVER ]; then
        if ! [ -f "$SERVER.zip" ]; then
            log ERROR "server repo for ${YELLOW}${APP_NAME}${RED} is missing. Aborting !!"
            exit 1
        else
            display_progress "Extracting Server package\n"
            unzip "$SERVER.zip" >>/dev/null
        fi
    fi
    cd $SERVER
    if ! [ -d node_modules ]; then
        display "Installing Server dependencies"
        npm i
        log "Server Dependencies installed"
    else
        log "Server dependencies already installed"
    fi
    npm start 1>/dev/null 2>error.log &
    #check build error
    if [ -s ./error.log ]; then
        log "Something went wrong while starting up the backend server. For more details please check $(echo $(PWD))/error.log"
        exit 1
    fi
    rm error.log

    cd ../
    if ! [ -d $UI ]; then
        if ! [ -f "$UI.zip" ]; then
            log ERROR "ui repo for ${YELLOW}${APP_NAME}${RED} is missing. Aborting !!"
            exit 1
        else
            display_progress "\n\nExtracting UI package\n"
            unzip "$UI.zip" >>/dev/null
        fi
    fi
    cd $UI
    if ! [ -d node_modules ]; then
        display "Installing UI dependencies"
        npm install
        log "UI Dependencies installed"
    else
        log "UI dependencies already installed"
    fi
    if command_exists ng; then
        log "Angular already installed"
    else
        npm install -g @angular/cli
        npm install -g @angular-devkit/build-angular
    fi

    display "Building application"

    npm start 1>Ui.log 2>error.log &
    while ! grep -q "Compiled successfully" Ui.log; do
        sleep 5
        if [ -s ./error.log ] && ! grep -q "Generating" error.log; then
            log "Something went wrong while starting up the UI server. For more details please check $(echo $(PWD))/error.log"
            exit 1
        fi
    done
    log "BUILD COMPLETE !"
    log "Application is running on http://localhost:4200/"
    rm -f Ui.log
    rm -f error.log
    cd ..
}

display "Initialising setup"
sleep 1

OsType=$(uname -s)
case $OsType in

# MacOS
Darwin*)
    if ! command_exists brew; then
        read -r -p "To continue with the setup, HomeBrew needs to be installed. Press 'Y' to continue, any other key to abort " ch
        if [ "$ch" == "Y" ] || [ "$ch" == "y" ]; then
            log "Installing Hombrew"
            /bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'
        else
            abort
        fi
    fi

    #Check if node is installed
    if ! command_exists node; then
        read -r -p "To run the application, NodeJS needs to be installed. Press 'Y' to continue, any other key to abort " ch
        if [ $ch == "Y" ] || [ $ch == "y" ]; then
            display "Installing nodejs"
            brew install node >>server.log 2>server.log
        else
            abort
        fi
    else
        upgrade_node "Darwin"
    fi
    ;;

# Ubuntu
Linux*)
    if ! command_exists node; then
        read -r -p "To run the application, NodeJS needs to be installed. Press 'Y' to continue, any other key to abort " ch
        if [ $ch == "Y" ] || [ $ch == "y" ]; then
            display "Installing NodeJS"
            sudo apt install nodejs >>server.log 2>server.log
        else
            abort
        fi
    else
        upgrade_node "Linux"
    fi
    ;;

# Windows
CYGWIN* | MINGW32* | MSYS* | MINGW*)
    if ! command_exists node; then
        read -r -p "To run the application, NodeJS needs to be installed. Press 'Y' to continue, any other key to abort " ch
        if [ $ch == "Y" ] || [ $ch == "y" ]; then
            display "Installing NodeJS"
            log "Use this link to download and update nodejs" "${NODEJS_WIN_INSTALLER}"
            read -r -p "Before continuing, make sure nodejs has been installed. Press 'Y' to continue, any other key to abort " ch
            if ([ $ch == "Y" ] || [ $ch == "y" ]) && ! command_exists node; then
                log "NodeJs setup not complete. Run the script again or install it manually. Download and install it from here ${NODEJS_WIN_INSTALLER}"
                exit 1
            else
                abort
            fi
        else
            abort
        fi
    else
        upgrade_node "Windows"
    fi
    ;;
esac

run_application
