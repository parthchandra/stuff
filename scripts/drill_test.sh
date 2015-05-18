#!/bin/bash

SCRIPTNAME="DRILL_test"
source ${HOME}/work/scripts/drill_scripts_env.sh

drill_testing_dir="${drill_test_src}/testing"

export DRILL_HOME="${drill_install}"
export DRILL_TEST_DATA_DIR="${drill_testing_dir}/framework"
export HADOOP_INSTALL_LOC=""
export DRILL_TESTDATA="/tmp"
export ZOOKEEPERS="localhost:2181"
export TIME_OUT_SECONDS="10"

cd ${drill_testing_dir}
mvn clean install > "${logfile} " 2>&1 &

tail -F "${logfile} "

