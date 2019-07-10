#!/bin/bash
################################################################################
# env.sh - Common constants between scripts
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

# These values will be used if parent caller does not have them already set
DEFAULT_PROJECT_ROOT="$HOME/git/gitflow-poc"
DEFAULT_CURRENT_DEV_VERSION="7.20170511-ua-release62"
DEFAULT_NEXT_DEV_VERSION="7.20170511-ua-release63"


# If the LHS is not already set, then DEFAULT_* will be used; helpful to have one version
# of constants that can be used on local cli, but also let jenkins override them w/ params
PROJECT_ROOT="${PROJECT_ROOT:=$DEFAULT_PROJECT_ROOT}"
CURRENT_DEV_VERSION="${CURRENT_DEV_VERSION:=$DEFAULT_CURRENT_DEV_VERSION}"
NEXT_DEV_VERSION="${NEXT_DEV_VERSION:=$DEFAULT_NEXT_DEV_VERSION}"
