#!/bin/bash +x
cmd=${1:-restart}
SCRIPTNAME="DRILL"
source ${HOME}/work/scripts/drill_scripts_env.sh

#drill_src=${DRILL_SRC:-~/work/drill}
cd ${drill_src}
echo "${cmd} Drill ..."
#version=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -e '^[[:digit:]]'`
#if [ -n "$DRILL_BIN" ]
#then
#    drill_bin=${DRILL_BIN}
#else
#    drill_bin="${drill_src}/distribution/target/apache-drill-${version}/apache-drill-${version}/bin"
#fi
echo "Found Drill version: ${version}. Looking for executable in ${drill_bin}"
cd ${drill_bin}
export PS1="[DRILL][\u@\h:apache-drill-${version}]>"
echo 
pwd
echo "${cmd} Drillbit apache-drill-${version}"
#if [ "${cmd}" = "debug" ]
#then
#    . ~/work/scripts/set_drill_debug_env.sh
#    echo restarting in debug mode
#    cmd="restart"
#fi
. ~/work/scripts/set_drill_debug_env.sh
sudo ./drillbit.sh ${cmd} --config ~/work/drill-conf
echo "Done"
#clear
#if [ "${cmd}" != "stop" ]
#then
    #clear 
    #. ~/work/scripts/drill_header.sh
    #tail -n0 -F /var/log/drill/drillbit.out 
#fi
