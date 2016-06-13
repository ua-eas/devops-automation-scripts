#!/bin/bash
kfsRepoUrl='git@github.com:ua-eas/kfs-devops-automation-fork.git'
# Prompt user for different URLs, if needed
echo -n "Input KFS repo URL (default: $kfsRepoUrl): "
read inputKfsRepoUrl
if [[ $inputKfsRepoUrl ]]; then
    echo "Using KFS repo Url: $inputKfsRepoUrl"
    kfsRepoUrl=$inputKfsRepoUrl
fi
echo -n "Enter a comma-separated list of branches to clean up (i.e. 'UAF-AAA,UAF-BBB,...,UAF-ZZZ') : "
IFS=',' read -ra branches
# Remove any existing temporary directory
rm -Rf /tmp/repo
git clone $kfsRepoUrl /tmp/repo/kfs
cd /tmp/repo/kfs

# For each branch, create and push to origin
for branch in "${branches[@]}"; do
    echo "Processing branch $branch"
    git checkout -b $branch ua-development
    git push origin $branch
done
