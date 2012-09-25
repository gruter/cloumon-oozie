# Set cloumon-oozie-specific environment variables here.
# JAVA_HOME, CLOUMON_OOZIE_HOME required

#JAVA HOME dir
export JAVA_HOME=/usr/java/default

#cloumon-oozie home dir
export CLOUMON_OOZIE_HOME=/usr/local/cloumon-oozie

#cloumon-oozie conf dir
export CLOUMON_OOZIE_CONF_DIR="${CLOUMON_OOZIE_HOME}/conf"

# JVM Heap Size (MB) of cloumon-oozie server
export CLOUMON_OOZIE_HEAPSIZE="-Xmx256m"

# The directory where pid files are stored. /tmp by default.
export CLOUMON_OOZIE_PID_DIR=~/.cloumon-oozie_pids

# A string representing this instance of cloumon-oozie. $USER by default.
# export CLOUMON_OOZIE_IDENT_STRING=$USER

# JVM Options of cloumon-oozie server
export CLOUMON_OOZIE_OPTS="$CLOUMON_OOZIE_HEAPSIZE"