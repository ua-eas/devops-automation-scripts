#!/bin/bash
repoUrl='git@bitbucket.org:uits-ksd/kfs-6-to-7-dbupgrade-sql.git'
developmentBranch="development"
masterBranch="master"
# Prompt user for different URLs, if needed
echo -n "Input repository URL (default: $repoUrl): "
read inputRepoUrl
if [[ $inputRepoUrl ]]; then
    echo "Using repo Url: $inputRepoUrl"
    repoUrl=$inputRepoUrl
fi

echo -n "Input master branch name (default: $masterBranch): "
read inputMasterBranch
if [[ $inputMasterBranch ]]; then
    echo "Using master branch name: $inputMasterBranch"
    masterBranch=$inputMasterBranch
fi

echo -n "Input development branch name (default: $developmentBranch): "
read inputDevelopmentBranch
if [[ $inputDevelopmentBranch ]]; then
    echo "Using development branch name: $inputDevelopmentBranch"
    developmentBranch=$inputDevelopmentBranch
fi

# echo out details for sanity purposes
echo ""
echo "Repository URL: $repoUrl"
echo "'master' branch name: $masterBranch"
echo "'development' branch name: $developmentBranch"
echo ""

# Have user verify values are OK before continuing
read -p "Press Enter to continue... "

git clone $repoUrl /tmp/repo/release
cd /tmp/repo/release

# Merge 'development' into 'master', push changes
git checkout $masterBranch
git pull origin $developmentBranch
git push origin $masterBranch
