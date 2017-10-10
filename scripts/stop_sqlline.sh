#!/bin/bash
kill `jps | grep -i sqlline | awk '{ print $1} '`
