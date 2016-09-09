#!/bin/bash
# Default repository URL values. 
# These are set to test repositories to avoid inadvertendly modifying main repositories
kfsHelpRepoUrl='git@github.com:ua-eas/kfs-help.git'
releasePrefix="ua-release"
# Prompt user for different URLs, if needed
echo -n "Input KFS help text repo URL (default: $kfsHelpRepoUrl): "
read inputkfsHelpRepoUrl
if [[ $inputkfsHelpRepoUrl ]]; then
    echo "Using KFS help text repo Url: $inputkfsHelpRepoUrl"
    kfsHelpRepoUrl=$inputkfsHelpRepoUrl
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

# Prompt user for a release prefix if different from default (mostly useful during development/testing)
echo -n "Input version prefix (default: $releasePrefix): "
read inputReleasePrefix
if [[ $inputReleasePrefix ]]; then
    echo "Using release prefix $inputReleasePrefix"
    releasePrefix=$inputReleasePrefix
fi

# Calculate the various version strings we'll need
releaseVersion="$releasePrefix$value"
developmentVersion="$releasePrefix$(($value+1))-SNAPSHOT"
previousReleaseVersion="$releasePrefix$(($value-1))"
previousDevelopmentVersion="$releasePrefix$(($value))-SNAPSHOT"

# echo out versions for sanity purposes
echo "Release version: $releaseVersion"
echo "Next development iteration: $developmentVersion"
echo "Previous release version: $previousReleaseVersion"
echo "Current development iteration: $previousDevelopmentVersion"

# Remove any existing temporary directory
rm -Rf /tmp/repo

# Check out KFS repo
git clone $kfsHelpRepoUrl /tmp/repo/kfs-help
cd /tmp/repo/kfs-help

# Utilize the jgitflow plugin to generate the release for KFS help text
# For more information: https://bitbucket.org/atlassian/jgit-flow
mvn -DskipTests=true jgitflow:release-start -DreleaseVersion=$releaseVersion -DdevelopmentVersion=$developmentVersion \
    -DscmCommentPrefix="$releaseTicketNumber " -DdefaultOriginUrl=$kfsHelpRepoUrl && \
mvn -DskipTests=true jgitflow:release-finish -DreleaseVersion=$releaseVersion -DdevelopmentVersion=$developmentVersion \
    -DscmCommentPrefix="$releaseTicketNumber " -DdefaultOriginUrl=$kfsHelpRepoUrl
