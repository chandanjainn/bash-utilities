#!/bin/bash
set -eou pipefail

GITHUB_USER=${GITHUB_USER:-"change me"}
GHE_TOKEN=${GHE_TOKEN:-"change me"}
GHE_SERVER=${GHE_SERVER:-"github.com"}
ISSUE_NUMBER=

COMMIT_MSG="<msg>"
BRANCH="<branch>"

open_PR() {
    sleep 5
    PR_URL=$(
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            --user "$GITHUB_USER:$GHE_TOKEN" \
            https://api.$GHE_SERVER/repos/$1/$2/pulls \
            -d '{"head":"'$3'","base":"'$4'","title":"<msg>"}' | jq '.url'
    )
    s='api/v3/repos/'
    PR_URL=${PR_URL/$s/}
    PR_URL=${PR_URL//\"/}
    PR_URL=${PR_URL//pulls/pull}
    curl \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        --user "$GITHUB_USER:$GHE_TOKEN" \
        https://api.$GHE_SERVER/repos/<org>/hq/issues/$ISSUE_NUMBER/comments \
        -d '{"body": "'$PR_URL'"}'
}

REPOS=(
    # add repos here <org>/<repo>
)

# Branches=(
#     "main"
# )

export URL1=""
export NEW_URL1=""

export STR='replace "na.artifactory.com-docker-local/" $registry | trim -}}'
export NEW_STR='replace "na.artifactory.com" $registry | replace "jfrog.io/docker-local/" $registry | trim -}}'

do_magic() {
    git_repo=$1
    repo=$(echo $git_repo | cut -d'/' -f2)
    org=$(echo $git_repo | cut -d'/' -f1)

    log "Working the magic on $repo"
    if ! [ -d "$org" ]; then
        mkdir $org && cd $org
        log "$repo not found locally. Cloning..."
        git clone -q --depth 1 "https://${GHE_TOKEN}@${GHE_SERVER}/$org/${repo}.git"
        cd $repo
    else
        cd $org
        if ! [ -d "$repo" ]; then
            log "$repo not found locally. Cloning..."
            git clone "https://${GHE_TOKEN}@${GHE_SERVER}/$org/${repo}.git"
        else
            log "$org/$repo exists. Pulling latest"
        fi
        cd $repo
        git pull
    fi

    base=main
    if ! [ -n "$(echo $(git show-ref refs/heads/main))" ]; then
        base=master
    fi

    if [ -z ${Branches:-""} ]; then
        Branches=($base)
    fi

    for branch in ${Branches[@]}; do
        git checkout $branch
        temp_branch=$BRANCH-$branch
        git checkout -b "$temp_branch"

        grep -rl "$STR" . | xargs ruby -p -i -e "gsub(ENV['STR'], ENV['NEW_STR'])" || true
        grep -rl --exclude=*.tpl "$URL1" . | xargs ruby -p -i -e "gsub(ENV['URL1'], ENV['NEW_URL1'])" || true

        git add .
        git commit -m "$COMMIT_MSG"
        log "Pushing the code to $temp_branch branch "
        git push --set-upstream origin $temp_branch

        open_PR $org $repo $temp_branch $branch

        log "Raising a pull request on github. Check $GHE_SERVER/$org/$repo/pulls"

        git checkout $base
    done
    cd ../..
}

for repo in ${REPOS[@]}; do
    do_magic $repo
done

