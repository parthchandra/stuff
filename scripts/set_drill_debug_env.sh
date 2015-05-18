#!/bin/bash
export JAVA_TOOL_OPTIONS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=5005,suspend=n"
#export JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
