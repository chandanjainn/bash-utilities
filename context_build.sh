#!/bin/bash

# This script is used to change the server endpoint at runtime where we need a dynamic backend endpoint
# 1. Replace all hardcoded instances of http://localhost:<port> with {HOSTNAME}
# 2. Then add the paths of the files to the below files array.
# 3. Modify your start script in package.json to "start": "bash context_build.sh && ng serve"

FILES=(
    "src/index.html"
    "src/styles.scss"
    "src/environments/environment.ts"
    "src/environments/environment.prod.ts"
)
HOSTNAME="http://localhost:3001"

ESCAPED_HOSTNAME=$(printf '%s\n' "$HOSTNAME" | sed -e 's/[]\/$*.^[]/\\&/g')

for file in ${FILES[@]}; do
    if [ "$1" == true ]; then
        sed "s/$ESCAPED_HOSTNAME/{HOSTNAME}/g" $file >"$file.txt"
    else
        sed "s/{HOSTNAME}/$ESCAPED_HOSTNAME/g" $file >"$file.txt"
    fi
    cp "$file.txt" $file && rm -f "$file.txt"
done
