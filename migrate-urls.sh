#!/bin/bash

## make sure you have KYN_GHE_TOKEN set as an environment variable

export LC_CTYPE=C
export LANG=C
KYN_GHE_SERVER=""

REPOS=(
    #add repos here
)

str1=""
ESCAPED_STR1=$(printf '%s\n' "$str1" | sed -e 's/[]\/$*.^[]/\\&/g')
replace1=""
ESCAPED_rpl1=$(printf '%s\n' "$replace1" | sed -e 's/[]\/$*.^[]/\\&/g')


for repo in ${REPOS[@]}; do
    git clone -q --depth 1 "https://${GHE_TOKEN}@${GHE_SERVER}/${repo}.git"
    dir=$(echo $repo | cut -d'/' -f2)
    cd $dir
    git checkout -b artifactory-migration

    find . -type f | xargs sed -i "" "s/$ESCAPED_STR1/$ESCAPED_rpl1/g"

    # grep -rl "$ESCAPED_STR1" . | xargs sed -i "" "s/$ESCAPED_STR1/$ESCAPED_rpl1/g"

    git add .
    git commit -m "chore: replaced ..."
    git push -u origin artifactory-migration
    cd ..
done
