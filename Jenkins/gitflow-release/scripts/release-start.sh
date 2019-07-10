#!/bin/bash
################################################################################
# release-start.sh - A script drive first phase of release cycle
#
# usage `$ ./release-start.sh`
#
# This script will create a new release branch from develop, adjust the version
# for pom artifacts, push the new release branch, and bump the develop version
# for the next cycle.
#
# v0.1a
#
#
# Copyright (C) 2019  University of Arizona
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
# -u: Using unset vars causes an error, killing some pernicious bugs
set -u


################################################################################
# Global constants: Jenkins params override these, if present
################################################################################
source "$PROJECT_ROOT/src/main/resources/scripts/env.sh"


################################################################################
# create_release_branch()
#
# This takes everything on the develop branch into a new 'release' branch
# (assumes that any other 'release' branch was deleted in the last cycle)
################################################################################
function create_release_branch() {
    git checkout -b release
}


################################################################################
# process_release_branch_version()
#
# The develop branch is always one version ahead from what has been released,
# and the develop version also has an appended '-SNAPSHOT' string; the following
# will hunt out all pom files, remove that '-SNAPSHOT', which is how we need it
# for the release artifacts
################################################################################
function process_release_branch_version() {
    # This truncates the '-SNAPSHOT' version from develop
    mvn versions:set -DgenerateBackupPoms=false -DremoveSnapshot=true -DnewVersion="$CURRENT_DEV_VERSION"
    git add .
    git commit -m "Jenkins: Setting pom release version: $CURRENT_DEV_VERSION"
}


################################################################################
# push_release_branch() - Persists new release branch to remote
################################################################################
function push_release_branch() {
    # Persist release branch
    git push --set-upstream origin release
}


################################################################################
# bump_develop_branch_version() - Change develop's version for next iteration
################################################################################
function bump_develop_branch_version() {
    git checkout develop
    mvn versions:set -DgenerateBackupPoms=false -DnewVersion="$NEXT_DEV_VERSION-SNAPSHOT"
    git add .
    git commit -m "Jenkins: Bumping version to: $NEXT_DEV_VERSION-SNAPSHOT"
    git push
}


################################################################################
# main() - Driver function
################################################################################
function main {
    cd "$PROJECT_ROOT"

    create_release_branch
    process_release_branch_version
    push_release_branch
    bump_develop_branch_version
}


################################################################################
# Kick it off yo
################################################################################
main
