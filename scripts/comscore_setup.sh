#!/bin/bash
NQUERIES=${3:-1}
C1=${2:-25}
DATE=${1:-31}

for j in $(seq -f "%02g" 1 ${DATE})
# for ((j=1;j<=${DATE};j++));
do
    dt="2015-10-${j}"
    mkdir $dt
    cd $dt
    for k in $(seq -f "%02g" 1 ${C1})
    #for ((k=1;k<=${C1};k++));
    do
        c1="c1-${k}"
        mkdir $c1
        cd $c1

        for ((l=1;l<=${NQUERIES};l++));
        do
            #remember to escape the asterix
           qry=" create table dfs.\`\/$dt\/$c1\` as select $l as query_num, $dt as date_col,  $c1 as c1_col, lineitem.\* from lineitem"
           echo "$qry"
        done # for NQUERIES
        cd ..
    done # for C1
    cd ..
done #for DATE

