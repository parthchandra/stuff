#!/bin/bash

rc=0
if [ -f $1.md5 ]; then
    if [ "$(cat $1.md5)" = "$(openssl md5 $1 | cut -d ' ' -f 2)" ]; then
        echo "md5 present and Ok"
    else
        echo "md5 does not match"
        rc=1
    fi
fi

if [ -f $1.sha1 ]; then
    if [ "$(cat $1.sha1)" = "$(openssl sha1 $1 | cut -d ' ' -f 2)" ]; then
        echo "sha1 present and Ok"
    else
        echo "sha1 does not match"
        rc=2
    fi
fi

if [ -f $1.sha512 ]; then
    if [ "$(cat $1.sha512)" = "$(openssl sha1 -sha512 $1 | cut -d ' ' -f 2)" ]; then
        echo "sha512 present and Ok"
    else
        echo "sha512 does not match"
        rc=3
    fi
fi

if [ -f $1.asc ]; then
    echo "GPG verification output"
    rc=`gpg --verify $1.asc $1`  
fi
exit $rc
