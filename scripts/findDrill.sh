#!/bin/bash

drill_src=${DRILL_SRC:-~/work/drill}

if [ -n "$PS1" ] 
then
    if [ ! -n "${drill_bin}" ]
    then
        pushd ${drill_src} >& /dev/null
        version=`mvn --non-recursive org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -e '^[[:digit:]]'`
        drill_bin="${drill_src}/distribution/target/apache-drill-${version}/apache-drill-${version}/bin"
        if [ -f ~/work/stuff/drill-conf/drill-env.sh ]
        then
            ln -s ${drill_bin}/../conf/drill-env.sh ~/work/stuff/drill-conf/drill-env.sh
        fi
        popd >& /dev/null
    fi
fi

if [ -d ${drill_bin} ] 
then
    export DRILL_BIN=${drill_bin}
fi
if [ -d ${drill_src} ] 
then
    export DRILL_SRC=${drill_src}
fi
if [ -n "${version}" ] 
then
    export DRILL_VERSION=${version}
fi

