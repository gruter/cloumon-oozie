#!/usr/bin/env bash
# 
# Runs a cloumon-oozie command as a daemon.
#
# Environment Variables
#
##

usage="Usage: cloumon-oozie-daemon.sh (start|stop) <command>"

# if no args specified, show usage
if [ $# -le 1 ]; then
  echo $usage
  exit 1
fi

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/cloumon-oozie-env.sh

startStop=$1
shift
command=$1
shift

cloumon-oozie_rotate_log ()
{
    log=$1;
    num=5;
    if [ -n "$2" ]; then
	num=$2
    fi
    if [ -f "$log" ]; then # rotate logs
	while [ $num -gt 1 ]; do
	    prev=`expr $num - 1`
	    [ -f "$log.$prev" ] && mv "$log.$prev" "$log.$num"
	    num=$prev
	done
	mv "$log" "$log.$num";
    fi
}

if [ "$CLOUMON_OOZIE_LOG_DIR" = "" ]; then
  export CLOUMON_OOZIE_LOG_DIR="$CLOUMON_OOZIE_HOME/logs"
fi
mkdir -p "$CLOUMON_OOZIE_LOG_DIR"

if [ "$CLOUMON_OOZIE_PID_DIR" = "" ]; then
  CLOUMON_OOZIE_PID_DIR=/tmp
fi

if [ "$CLOUMON_OOZIE_IDENT_STRING" = "" ]; then
  export CLOUMON_OOZIE_IDENT_STRING="$USER"
fi

# some variables
export CLOUMON_OOZIE_LOGFILE=cloumon-oozie-$CLOUMON_OOZIE_IDENT_STRING-$command-`hostname`.log
export CLOUMON_OOZIE_ROOT_LOGGER="INFO,DRFA"
log=$CLOUMON_OOZIE_LOG_DIR/cloumon-oozie-$CLOUMON_OOZIE_IDENT_STRING-$command-`hostname`.out
pid=$CLOUMON_OOZIE_PID_DIR/cloumon-oozie-$CLOUMON_OOZIE_IDENT_STRING-$command.pid

if [ ! -e $CLOUMON_OOZIE_PID_DIR ]; then
    mkdir $CLOUMON_OOZIE_PID_DIR
fi
    
case $startStop in

  (start)

    if [ -f $pid ]; then
      if kill -0 `cat $pid` > /dev/null 2>&1; then
        echo $command running as process `cat $pid`.  Stop it first.
        exit 1
      fi
    fi

    cloumon-oozie_rotate_log $log
    echo starting $command, logging to $log
    nohup nice -n 0 "$CLOUMON_OOZIE_HOME"/bin/cloumon-oozie $command "$@" > "$log" 2>&1 < /dev/null &
    echo $! > $pid
    sleep 1; head "$log"
    ;;
          
  (stop)

    if [ -f $pid ]; then
      if kill -9 `cat $pid` > /dev/null 2>&1; then
        echo stopping $command
        kill `cat $pid`
      else
        echo no $command to stop
      fi
    else
      echo no $command to stop
    fi
    ;;

  (*)
    echo $usage
    exit 1
    ;;

esac
