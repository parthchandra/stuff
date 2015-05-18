SCRIPTNAME="MEM_LEAK_QUERIES"
source ${HOME}/work/scripts/drill_scripts_env.sh

CMDDIR="${client_build_dir}/Debug"
ITER=${1:-10}
TYPE="type=sql"
API="api=sync"
CONNECTSTR="connectStr=zk=localhost:2181/drill/drillbits1"
LOGLEVEL="logLevel=error"

#$(cat << EOQ
#EOQ
#)

#main
for ((j=1;j<=${ITER};j++));
do
    printf " Running iteration ${j} on query set ${i}                    \n " >&2
    #CMD="${CMDDIR}/querySubmitter '${TYPE}' '${API}' '${CONNECTSTR}' '${LOGLEVEL}' '${QRY}' "
    #echo ${CMD}
    #eval ${CMD}
    ${CMDDIR}/querySubmitter $TYPE $API $CONNECTSTR $LOGLEVEL 'query=select supp_nation, cust_nation, l_year, sum(volume) as revenue from ( select n1.n_name as supp_nation, n2.n_name as cust_nation, extract(year from l.l_shipdate) as l_year, l.l_extendedprice * (1 - l.l_discount) as volume from dfs.`/Users/pchandra/work/data/tpc-h/supplier.parquet` s, dfs.`/Users/pchandra/work/data/tpc-h/lineitem.parquet` l, dfs.`/Users/pchandra/work/data/tpc-h/orders.parquet` o, dfs.`/Users/pchandra/work/data/tpc-h/customer.parquet` c, dfs.`/Users/pchandra/work/data/tpc-h/nation.parquet` n1, dfs.`/Users/pchandra/work/data/tpc-h/nation.parquet` n2 where s.s_suppkey = l.l_suppkey and o.o_orderkey = l.l_orderkey and c.c_custkey = o.o_custkey and s.s_nationkey = n1.n_nationkey and c.c_nationkey = n2.n_nationkey and ( (n1.n_name = '\''EGYPT'\'' and n2.n_name = '\''UNITED STATES'\'') or (n1.n_name = '\''UNITED STATES'\'' and n2.n_name = '\''EGYPT'\'')) and l.l_shipdate between date '\''1995-01-01'\'' and date '\''1996-12-31'\'') as shipping group by supp_nation, cust_nation, l_year order by supp_nation, cust_nation, l_year '

done
printf "\n" >&2

