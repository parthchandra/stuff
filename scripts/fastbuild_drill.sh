#!/bin/bash

SCRIPTNAME="DRILL_FASTBUILD"
source ${HOME}/work/scripts/drill_scripts_env.sh

profile=${1:-default-hadoop}
cd ${drill_src}

echo "Building Drill profile ${profile}. Logging output to ${logfile}"
rm -fr "log.path_IS_UNDEFINED"
mvn clean install -DskipTests -DskipJdbcAll > "${logfile}" 2>&1  & 

xterm -bg "cyan" -title "Drill Fast build ${datetime} " -sb -sl 10240 -e "tail -F ${logfile} " &
# Ring a bell when done
wait %1 
echo -e '\a' || (echo -e '\a'; sleep 1; echo -e '\a')
if [ "${os}" == "Darwin" ] 
then
    osascript -e 'tell app "System Events" to display dialog "Drill Fast Build Complete"'   
fi
