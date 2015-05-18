#!/bin/bash +x
#cmd=${1:-restart}
parquet_tools_home=${PARQUET_TOOLS_HOME:-~/work/incubator-parquet-mr/parquet-tools}
cd ${parquet_tools_home}

mvn dependency:copy-dependencies
mkdir lib
cp  src/main/scripts/* .
cd lib
cp ../target/*.jar .
ln -s ../target/dependency/*.jar .

