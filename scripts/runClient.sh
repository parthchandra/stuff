#! /bin/bash

#   USAGE 
#   runClient.sh NUM_ITERATIONS API  TESTCANCEL
#
#

SCRIPTNAME="DRILL_CLIENT_TEST"
source ${HOME}/work/scripts/drill_scripts_env.sh

CMDDIR="${client_build_dir}/Debug"
ITER=${1:-100}
TYPE="sql"
API=${2:-"sync"}
CONNECTSTR="zk=localhost:2181/drill/drillbits1"
LOGLEVEL="trace"
TESTCANCEL=${3:-"false"}
#CONNECTSTR="jdbc:drill:local=127.0.0.1:31010"

IFS=$'\r\n' 
GLOBIGNORE='*' :; 
QUERIES="$(< ${HOME}/work/scripts/queries.txt)" #queries
NQUERIES=${#QUERIES[@]}
#echo ${QUERIES}

#plan='/Users/pchandra/work/data/tpc-h/parquet_scan_union_screen_physical.json'
#plan='/Users/pchandra/work/data/tpc-h/file_not_there.json'


for QRY in $QUERIES
do
    for ((j=1;j<=${ITER};j++));
    do
        printf " Running iteration ${j} on query set ${i}                    \n " >&2
        CMD="${CMDDIR}/querySubmitter 'type=${TYPE}' 'api=${API}' 'connectStr=${CONNECTSTR}' 'query=${QRY}' 'logLevel=${LOGLEVEL}' 'testCancel=${TESTCANCEL}'"
        echo "EXECUTING ${CMD}"
        eval ${CMD} 
    done
    printf "\n" >&2
done

