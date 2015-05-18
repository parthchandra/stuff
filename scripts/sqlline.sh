#!/bin/bash +x
SCRIPTNAME="SQLLINE"
source ${HOME}/work/scripts/drill_scripts_env.sh

#drill_home=${DRILL_HOME:-~/work/drill}
cd ${drill_src}
#version=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -e '^[[:digit:]]'`
#drill_bin="${drill_home}/distribution/target/apache-drill-${version}/apache-drill-${version}/bin"
echo ${drill_bin}
cd ${drill_bin}
export PS1="[SQLLINE][\u@\h:apache-drill-${version}]>"
clear
echo 
export JAVA_TOOL_OPTIONS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=5015,suspend=n"
echo "Sqlline apache-drill-${version}"
#sudo ./sqlline -u "jdbc:drill:zk=localhost:2181"  -n admin -p admin --showNestedErrs=false
#sudo ./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010"  -n admin -p admin --showNestedErrs=false
#sudo ./sqlline -u "jdbc:drill:schema=ericsson.canonical;drillbit=10.10.10.121:3101"  -n admin -p admin
#sudo ./sqlline -u "jdbc:drill:drillbit=localhost:31010;schema=foo"  -n admin -p admin --showNestedErrs=false
./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010"  -n admin -p admin --showNestedErrs=false
