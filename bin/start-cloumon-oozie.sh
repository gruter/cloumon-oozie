#!/usr/bin/env bash

# Start cloumon-oozie daemons.  Run this on master node.

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/cloumon-oozie-env.sh

"$bin"/cloumon-oozie-daemon.sh start webserver "$@"
