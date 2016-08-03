#!/bin/bash

function pause(){
    read -rsp $'Press any key to continue...\n' -n1 key
}

function runCmd(){
echo " ----------------- "  > ${DRILL_RELEASE_OUTFILE}
echo " ----------------- $1 "  | tee ${DRILL_RELEASE_OUTFILE}
echo " ----------------- "  > ${DRILL_RELEASE_OUTFILE}
shift
# run the command, send output to out file
"$@" >& ${DRILL_RELEASE_OUTFILE}
if [ $? -ne 0 ]; then
        echo FAILED to run $1 | tee ${DRILL_RELEASE_OUTFILE}
        exit 1
fi
#wait for user to verify and continue
pause
}

function copyFiles(){
    rm -fr ${LOCAL_RELEASE_STAGING_DIR}
    mkdir -p ${LOCAL_RELEASE_STAGING_DIR}/${DRILL_RELEASE_VERSION}
    cp ${DRILL_SRC}/target/apache-drill-${DRILL_RELEASE_VERSION}-src.tar.gz* ${LOCAL_RELEASE_STAGING_DIR}/${DRILL_RELEASE_VERSION}/ && \
    cp ${DRILL_SRC}/target/apache-drill-${DRILL_RELEASE_VERSION}-src.zip* ${LOCAL_RELEASE_STAGING_DIR}/${DRILL_RELEASE_VERSION}/ \
    cp ${DRILL_SRC}/distribution/target/apache-drill-${DRILL_RELEASE_VERSION}.tar.gz* ${LOCAL_RELEASE_STAGING_DIR}/${DRILL_RELEASE_VERSION}/  

}

function checkPassphrase(){
echo "1234" | gpg2 --batch --passphrase "${GPG_PASSPHRASE}" -o /dev/null -as - 
if [ $? -ne 0 ]; then
    echo "Invalid passphrase. Make sure the default key is set to the key you want to use (or make it the first key in the keyring)."
    exit 1
fi
}

function readInputAndSetup(){

    if [ -e "./drill-release-input.sh" ]
    then
        source "./drill-release-input.sh"
    fi

    if [ "${WORK_DIR}" = "" ]
    then
        read -p "Drill Working Directory : " WORK_DIR
    fi

    if [ "${DRILL_RELEASE_VERSION}" = "" ]
    then
    read -p "Drill Release Version (eg. 1.4.0) : " DRILL_RELEASE_VERSION
    fi

    if [ "${DRILL_DEV_VERSION}" = "" ]
    then
    read -p "Drill Development Version (eg. 1.5.0-SNAPSHOT) : " DRILL_DEV_VERSION
    fi

    if [ "${RELEASE_COMMIT_SHA}" = "" ]
    then
    read -p "Release Commit SHA : " RELEASE_COMMIT_SHA
    fi

    if [ "${DRILL_RELEASE_OUTDIR}" = "" ]
    then
    read -p "Write output to (directory) : " DRILL_RELEASE_OUTDIR
    fi

    if [ "${MY_REPO}" = "" ]
    then
    read -p "Staging (personal) repo : " MY_REPO
    fi

    if [ "${LOCAL_RELEASE_STAGING_DIR}" = "" ]
    then
    read -p "Local release staging directory : " LOCAL_RELEASE_STAGING_DIR
    fi

    if [ "${GPG_PASSPHRASE}" = "" ]
    then
    read -s -p "GPG Passphrase (Use quotes around a passphrase with spaces) : " GPG_PASSPHRASE
    fi


    DRILL_RELEASE_OUTFILE="${DRILL_RELEASE_OUTDIR}/drill_release.out.txt"
    DRILL_SRC=${WORK_DIR}/drill-release
    MY_REPO_NAME="Parth"

    echo ""
    echo "-----------------"
    echo "Drill Working Directory : " ${WORK_DIR}
    echo "Drill Src Directory : " ${DRILL_SRC}
    echo "Drill Release Version : " ${DRILL_RELEASE_VERSION}
    echo "Drill Development Version : " ${DRILL_DEV_VERSION}
    echo "Release Commit SHA : " ${RELEASE_COMMIT_SHA}
    echo "Write output to : " ${DRILL_RELEASE_OUTFILE}
    echo "Staging (personal) repo : " ${MY_REPO}
    echo "Local release staging dir : " ${LOCAL_STAGING_DIR}
    #echo "GPG Passphrase : " ${GPG_PASSPHRASE}


    touch ${DRILL_RELEASE_OUTFILE}
}

checkPassphrase(){
    # FIXME: The checkPassphrase function does not work for passphrases with embedded spaces.
    echo "Validating passphrase is disabled."
    #checkPassphrase && "Passphrase accepted"
}

cloneRepo(){
    cd ${WORK_DIR}
    rm -fr ./drill-release
    git clone https://github.com/apache/drill.git drill-release  >& ${DRILL_RELEASE_OUTFILE}
    cd ${DRILL_SRC}
    git checkout ${RELEASE_COMMIT_SHA}
}

###### BEGIN  #####

readInputAndSetup
checkPassphrase

runCmd "Cloning the repo" cloneRepo

runCmd "Checking the build" mvn install

export MAVEN_OPTS=-Xmx2g
runCmd "Clearing release history" mvn release:clean -Papache-release -DpushChanges=false -DskipTests

export MAVEN_OPTS='-Xmx4g -XX:MaxPermSize=512m' 
runCmd "Preparing the release " mvn -X release:prepare -Papache-release -DpushChanges=false -DskipTests -Darguments="-Dgpg.passphrase=${GPG_PASSPHRASE}  -DskipTests=true -Dmaven.javadoc.skip=false" -DreleaseVersion=${DRILL_RELEASE_VERSION} -DdevelopmentVersion=${DRILL_DEV_VERSION} -Dtag=drill-${DRILL_RELEASE_VERSION}

#git remote add ${MY_REPO_NAME} ${MY_REPO} 
runCmd "Pushing to private repo ${MY_REPO}" git push ${MY_REPO} drill-${DRILL_RELEASE_VERSION} 

runCmd "Performing the release to ${MY_REPO}" mvn release:perform -DconnectionUrl=scm:git:${MY_REPO} -DskipTests -Darguments="-Dgpg.passphrase=${GPG_PASSPHRASE} -DskipTests=true -DconnectionUrl=scm:git:${MY_REPO}" 

runCmd "Checking out release commit" git checkout drill-${DRILL_RELEASE_VERSION}

#Remove surrounding quotes
tempGPG_PASSPHRASE="${GPG_PASSPHRASE%\"}"
tempGPG_PASSPHRASE="${tempGPG_PASSPHRASE#\"}"
runCmd "Deploying ..." mvn deploy -Papache-release -DskipTests -Dgpg.passphrase="${tempGPG_PASSPHRASE}"

runCmd "Copying" copyFiles

#echo "Check artifacts are signed correctly"
runCmd "Verifying artifacts are signed correctly" checksum.sh ${DRILL_SRC}/distribution/target/apache-drill-${DRILL_RELEASE_VERSION}.tar.gz
pause

echo "Copy release files to home.apache.org"
echo 
echo 
echo "  sftp -i <apache_pvt_key> parthc@home.apache.org"
echo "    mkdir public_html"
echo "    cd public_html"
echo "    mkdir drill/releases/1.6.0"
echo "    cd drill/releases/1.6.0"
echo "    mkdir rc0"
echo "    cd rc0"
echo "    put ${LOCAL_STAGING_DIR}/${DRILL_RELEASE_VERSION} "
pause

echo "Go to the Apache maven staging repo and close the new jar release"
pause

echo "Start the vote \(good luck\)\n"

