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
#clear
echo 
export JAVA_TOOL_OPTIONS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=5015,suspend=n"
echo "Sqlline apache-drill-${version}"

#localhost - via zookeeper
./sqlline -u "jdbc:drill:zk=localhost:2181"  -n admin -p admin --showNestedErrs=false

#default - localhost (direct)
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010"  -n admin -p admin --showNestedErrs=false
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010" --showNestedErrs=false

#ericsson
#./sqlline -u "jdbc:drill:schema=ericsson.canonical;drillbit=10.10.10.121:3101"  -n admin -p admin

#bogus schema
#./sqlline -u "jdbc:drill:drillbit=localhost:31010;schema=foo"  -n admin -p admin --showNestedErrs=false

#error - empty truststore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010;drill.exec.security.user.encryption.ssl.enabled=true;javax.net.ssl.trustStore=/Users/pchandra/work/drill/exec/java-exec/src/test/resources/ssl/emptytruststore.ks;javax.net.ssl.trustStorePassword=drill123"  -n admin -p admin --showNestedErrs=false

#using the truststore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010;drill.exec.security.user.encryption.ssl.enabled=true;javax.net.ssl.trustStore=/Users/pchandra/work/drill/exec/java-exec/src/test/resources/ssl/truststore.ks;javax.net.ssl.trustStorePassword=drill123"  -n 121admin -p 123admin --showNestedErrs=false
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010;TLSProtocol=TLSv1.2;enableTLS=true;trustStorePath=/Users/pchandra/work/drill-conf/ssl/truststore.ks;trustStorePassword=drill123;disableHostVerification=true"  -n 121admin -p 123admin --showNestedErrs=false

#usingsystem truststore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=localhost:31010;TLSProtocol=TLSv1.2;enableTLS=true;useSystemTrustStore=true;trustStoreType=KeychainStore"  -n 121admin -p 123admin --showNestedErrs=false

#bug28401
#./sqlline -u "jdbc:drill:schema=dfs.root;drillbit=10.10.101.115:31010"  -n root -p root --showNestedErrs=false -f ~/work/scripts/bug28041.sql >/dev/null

#
#  REMOTE - Linux VM(s)
#

# plain
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;enableTLS=false"  -n 121admin -p 123admin --showNestedErrs=false

#error - No truststore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;drill.exec.security.user.encryption.ssl.enabled=true;javax.net.ssl.trustStorePassword=drill123"  -n 121admin -p 123admin --showNestedErrs=false

#Using the trustsore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;enableTLS=true;trustStorePath=/Users/pchandra/work/drill-conf/ssl/truststore.ks;trustStorePassword=drill123" --showNestedErrs=false

#using system truststore
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;enableTLS=true;useSystemTrustStore=true;trustStoreType=KeychainStore"  -n 121admin -p 123admin --showNestedErrs=false

# using keystore instead of truststore if the keystore has a certificate for the server
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;drill.exec.security.user.encryption.ssl.enabled=true;javax.net.ssl.keyStore=/Users/pchandra/work/drill/exec/java-exec/src/test/resources/ssl/keystore.ks;javax.net.ssl.keyStorePassword=drill123"  -n 121admin -p 123admin --showNestedErrs=false

#Using the trustsore, user credentials
#./sqlline -u "jdbc:drill:schema=dfs.work;drillbit=10.10.10.121:31010;drill.exec.security.user.encryption.ssl.enabled=true;javax.net.ssl.trustStore=/Users/pchandra/work/drill/exec/java-exec/src/test/resources/ssl/truststore.ks;javax.net.ssl.trustStorePassword=drill123"  -n mapr -p mapr --showNestedErrs=false
