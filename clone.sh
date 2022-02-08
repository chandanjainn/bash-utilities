ORG=${changeme:-chandanjainn}
GITHUB_USER=${changeme:-chandanjainn}
GIT_TOKEN=${changeme:-$GITHUB_TOKEN}
GHE_SERVER=${changeme:-github.com}

curl --user "$GITHUB_USER:$GIT_TOKEN" "https://api.$GHE_SERVER/orgs/$ORG/repos?per_page=100/" | grep -o 'git@[^"]*' | xargs -L1 git clone
