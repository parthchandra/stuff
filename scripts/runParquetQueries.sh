#!/bin/bash
SCRIPTNAME="RUN_PARQUET_QUERIES"
source ${HOME}/work/scripts/drill_scripts_env.sh
#${drill_bin}/sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010"  -n admin -p admin --showNestedErrs=false --force -f parquetQueries.sql > ~/work/temp/parquetTests.data..out.txt 2>~/work/temp/parquetTests.queries.out.txt
${drill_bin}/sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010"  -n admin -p admin --showNestedErrs=false --force -f parquetQueries.sql > /dev/null 2>${logfile}

more ${logfile}
