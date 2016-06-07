#!/bin/bash
# Default repository URL values. 
# These are set to test repositories to avoid inadvertendly modifying main repositories
kfsRepoUrl='https://github.com/ua-eas/kfs-devops-automation-fork'
dockerRepoUrl='https://github.com/ua-eas/devops-automation-docker-kfs6'

# Prompt user for different URLs, if needed
echo -n "Input KFS repo URL (default: $kfsRepoUrl): "
read inputKfsRepoUrl
if [[ $inputKfsRepoUrl ]]; then
    echo "Using KFS repo Url: $inputKfsRepoUrl"
    kfsRepoUrl=$inputKfsRepoUrl
fi

echo -n "Input Docker repo URL (default: $dockerRepoUrl): "
read inputDockerRepoUrl
if [[ $inputDockerRepoUrl ]]; then
    echo "Using KFS repo Url: $inputDockerRepoUrl"
    dockerRepoUrl=$inputDockerRepoUrl
fi

# Prompt user for the release ticket number to prepend to commit messages
echo -n "Input release ticket number: "
read releaseTicketNumber
if [[ -z "$releaseTicketNumber" ]]; then
    echo "Release ticket number must be entered!"
    exit    
fi

# Some math needs to be done on the version number, so it must be declared as an integer before being used
declare -i value

# Read the input version number from the user
echo -n "Input release version number (just the number): "
read value

# Since 'value' is declared as an integer, it is initialized as 0. 
# If no version is entered by the user, it will still be 0, which is an invalid build version
if [ $value -eq 0 ]; then
    echo "Release version must be entered!"
    exit
fi

# Calculate the various version strings we'll need
releaseVersion="ua-release$value"
developmentVersion="ua-release$(($value+1))-SNAPSHOT"
previousReleaseVersion="ua-release$(($value-1))"
previousDevelopmentVersion="ua-release$(($value))-SNAPSHOT"

# echo out versions for sanity purposes
echo "Release version: $releaseVersion"
echo "Next development iteration: $developmentVersion"
echo "Previous release version: $previousReleaseVersion"
echo "Current development iteration: $previousDevelopmentVersion"

#TODO make working dir configurable?
# Remove any existing temporary directory
rm -Rf /tmp/repo

# Check out KFS repo
git clone $kfsRepoUrl /tmp/repo/kfs
cd /tmp/repo/kfs
# Utilize the jgitflow plugin to generate the release for KFS
# For more information: https://bitbucket.org/atlassian/jgit-flow
mvn -DskipTests=true jgitflow:release-start -DreleaseVersion=$releaseVersion -DdevelopmentVersion=$developmentVersion -DscmCommentPrefix="$releaseTicketNumber " && \
     mvn -DskipTests=true jgitflow:release-finish -DreleaseVersion=$releaseVersion -DdevelopmentVersion=$developmentVersion -DscmCommentPrefix="$releaseTicketNumber "

# Check out Docker repo
git clone $dockerRepoUrl /tmp/repo/docker
cd /tmp/repo/docker
git checkout development
# Need to increment versions that are configured for the various Docker environments
sed -i "s/ENV KFS_VERSION_DEV=$previousDevelopmentVersion/ENV KFS_VERSION_DEV=$developmentVersion/g" /tmp/repo/docker/Dockerfile
sed -i "s/ENV KFS_VERSION_TST=$previousDevelopmentVersion/ENV KFS_VERSION_TST=$developmentVersion/g" /tmp/repo/docker/Dockerfile
sed -i "s/ENV KFS_VERSION_STG=$previousReleaseVersion/ENV KFS_VERSION_STG=$releaseVersion/g" /tmp/repo/docker/Dockerfile
# See the original manual steps confluence page for description of these steps.
# Essentially follows Git Flow, using the release ticket number as the name of the release branch

git checkout -b $releaseTicketNumber development
git commit -am "$releaseTicketNumber Updating kfs version for release $releaseVersion"
git push origin "$releaseTicketNumber"
git checkout development
git merge -m "$releaseTicketNumber Merging release branch $releaseTicketNumber for release $releaseVersion" "$releaseTicketNumber" #TODO add message
git push origin development
git checkout master
git pull
git merge -m "$releaseTicketNumber Merging release branch $releaseTicketNumber for release $releaseVersion" "$releaseTicketNumber" #TODO add message
git push origin master

# Clean up release branch
git checkout $releaseTicketNumber
git tag archive/$releaseTicketNumber $releaseTicketNumber
git push origin --tags
git push origin --delete $releaseTicketNumber
git checkout development
git branch -d $releaseTicketNumber

#TODO delete temp directory? May want to keep around for debugging purposes, especially since removing an existing is already done
