#!/bin/bash
SCRIPTNAME="CLIENT_BUILD"
source ${HOME}/work/scripts/drill_scripts_env.sh
#profile=${1:-default-hadoop}
#drill_src=${DRILL_SRC:-~/work/drill}
#logdir="/Users/pchandra/work/logs/builds"
#dtstamp=`date +%Y%m%d-%H%M%S`
#version=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -e '^[[:digit:]]'`

#CURRENTDIR=`pwd`
#DRILLCLIENTDIR=${CURRENTDIR}
#DRILLCLIENTDIR=${drill_src}/contrib/native/client
#BUILDDIR=${DRILLCLIENTDIR}/build
#cd ${DRILLCLIENTDIR}
cd ${drill_client_dir}

#echo "Current Directory is: ${DRILLCLIENTDIR}"
#echo "Build Directory is: ${BUILDDIR}"

IDE=${1:-Xcode}
BUILDTYPE=${2:-Debug}

echo "Building for: ${IDE}"
echo "Build Type: ${BUILDTYPE}"

if [ ! -e ${client_build_dir} ]
then
    mkdir build
fi

cd ${client_build_dir}

echo "Saving Settings ..."
tar xvf ~/work/temp/drillclient-${dtstamp}.xcodeproj.tar >& /tmp/drill-client-tar-save.out

rm -fr Debug Release protobuf src CMake* cmake*

cmake -G "${IDE}" -D "CMAKE_BUILD_TYPE=${BUILDTYPE}" ..

echo "Restoring Settingsi ..."
cd ${client_build_dir}/drillclient.xcodeproj
tar xvf ~/work/temp/drillclient-${dtstamp}-.xcodeproj.tar "drillclient.xcodeproj/xcuserdata" >& /tmp/drill-client-tar-restore.out
cd ${client_build_dir}

echo " Building"
#For XCode only
xcodebuild -project drillclient.xcodeproj -target fixProtobufs 
xcodebuild -project drillclient.xcodeproj -target cpProtobufs
xcodebuild -project drillclient.xcodeproj -target ALL_BUILD

