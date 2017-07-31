#!/bin/bash

# Directory to create the build directory in
export WORK_DIR="/Users/pchandra/work"

# release version
export DRILL_RELEASE_VERSION="1.11.0" 

# next development release version
export DRILL_DEV_VERSION="1.12.0-SNAPSHOT" 

# commit id on which to base the release
export RELEASE_COMMIT_SHA="64ab0a8ec9d98bf96f4d69274dddc180b8efe263" 

#Directory in which the release script writes its output log
export DRILL_RELEASE_OUTDIR="/Users/pchandra/work/temp"

#Personal github repository of the release manager
export MY_REPO="https://github.com/parthchandra/drill.git"

#directory to copy the release artifacts to 
export LOCAL_RELEASE_STAGING_DIR="/Users/pchandra/work/drill-staging"

# Apache login
export APACHE_LOGIN="parthc"

# release candidate attempt
export RELEASE_ATTEMPT="0"
