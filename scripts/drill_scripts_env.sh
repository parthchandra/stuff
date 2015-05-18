#!/bin/bash

script_name=${SCRIPTNAME:-"UNKNOWN"}
drill_src=${DRILL_SRC:-~/work/drill}
drill_test_src=${DRILL_TEST_SRC:-~/work/drill-test}
profile=${DRILL_BUILD_PROFILE:-default-hadoop}
logdir="${HOME}/work/logs/builds"
dtstamp=`date +%Y%m%d-%H%M%S`
drill_client_dir=${drill_src}/contrib/native/client
client_build_dir=${drill_client_dir}/build
cwd=`pwd`
os=`uname -a | awk '{ print $1}'`

if [ ! -n ${DRILL_VERSION} ]
then
    cd ${drill_src}
    version=`mvn --non-recursive org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -e '^[[:digit:]]'`
    cd ${cwd}
else
    version=${DRILL_VERSION}
fi

if [ -n "$DRILL_INSTALL" ]
then
    drill_install=${DRILL_INSTALL}
else
    drill_install="${drill_src}/distribution/target/apache-drill-${version}/apache-drill-${version}"
fi

if [ -n "$DRILL_BIN" ]
then
    drill_bin=${DRILL_BIN}
else
    drill_bin="${drill_install}/bin"
fi

logfile=${logdir}/${script_name}-${profile}-${dtstamp}.txt

echo "SCRIPT            : $script_name"
echo "DRILL SRC         : $drill_src"
echo "BUILD PROFILE     : $profile"
echo "DRILL VERSION     : $version"
echo "SCRIPT LOG DIR    : $logdir"
echo "SCRIPT LOG FILE   : $logfile"
echo "DRILL CLIENT      : $drill_client_dir"
echo "DRILL CLIENT BUILD: $client_build_dir"
echo "DATETIME          : $dtstamp"
echo "CURRENT DIR       : $cwd"
echo "DRILL INSTALL     : $drill_install"
echo "DRILL BIN         : $drill_bin"
echo "OS                : $os"
