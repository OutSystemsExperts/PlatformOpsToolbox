#!bin/bash
usage="
SYNOPSIS
    $(basename "$0") [-hdi] [directory interval(ms)]

DESCRIPTION
	This script gets the JAVA VMID of JBoss, JBoss MQ and the OutSystems services.
	Outputs the jstat statistics to a file for each VMID

OPTIONS
    -d [directory], -i [interval(ms)

    -h             show this help text
    -d             the directory where the output jstat files will be created
    -i             interval in miliseconds for each value output of jstat

================================================================
IMPLEMENTATION
    version         $(basename "$0") (www.outsystems.com) 0.1
    author          Duarte Santos
    copyright       Copyright (c) http://www.outsystems.com
    license         GNU General Public License

================================================================
HISTORY
     2016/02/11 : dms : First release
     2016/09/05 : dms : Review for public release
"

while getopts ':hd:i:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    d) DIR=$OPTARG
       ;;
    i) INTERVALMS=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac

done

shift $((OPTIND - 1))

if [[ -z $DIR ]] || [[ -z $INTERVALMS ]]
then
     echo "$usage"
     exit 1
                                                                                                                                                                                                                                                              1,6           Top
     echo "$usage"
     exit 1
fi

# Find out JBoss standalone process IDs
STANDALONE=$(sudo -u wildfly /etc/alternatives/java_sdk_1.8.0/bin/jps -lm | grep standalone-outsystems.xml | cut -d" " -f1)

# Find out JBoss mq process IDs
MQ=$(sudo -u wildfly /etc/alternatives/java_sdk_1.8.0/bin/jps -lm | grep standalone-outsystems-mq.xml | cut -d" " -f1)

# Find out OutSystems controller Java process IDs
CONTROLLER=$(sudo -u outsystems /etc/alternatives/java_sdk_1.8.0/bin/jps -l | grep deploymentcontroller | cut -d" " -f1)

# Find out OutSystems deployment Java process IDs
DEPLOYMENT=$(sudo -u outsystems /etc/alternatives/java_sdk_1.8.0/bin/jps -l | grep deployservice | cut -d" " -f1)

# Find out OutSystems scheduler Java process IDs
SCHEDULER=$(sudo -u outsystems /etc/alternatives/java_sdk_1.8.0/bin/jps -l | grep scheduler | cut -d" " -f1)

# Find out OutSystems log Java process IDs
LOG=$(sudo -u outsystems /etc/alternatives/java_sdk_1.8.0/bin/jps -l | grep logservice | cut -d" " -f1)

# Get system current date and time
DATEVAR=$(date '+%d%m%y-%H%M%S')

# Load the OutSystems Variables
. /etc/sysconfig/outsystems

# Commands that will be launched 
nohup sudo -u wildfly "$JAVA_HOME"/bin/jstat -gccause -t "$STANDALONE" "$INTERVALMS" > "$DIR"/jstat_standalone_"$DATEVAR".out 2>&1 &
nohup sudo -u wildfly "$JAVA_HOME"/bin/jstat -gccause -t "$MQ" "$INTERVALMS"  > "$DIR"/jstat_mq_"$DATEVAR".out 2>&1 &
nohup sudo -u outsystems "$JAVA_HOME"/bin/jstat -gccause -t "$CONTROLLER" "$INTERVALMS" > "$DIR"/jstat_controller_"$DATEVAR".out 2>&1 &
nohup sudo -u outsystems "$JAVA_HOME"/bin/jstat -gccause -t "$SCHEDULER" "$INTERVALMS"  > "$DIR"/jstat_scheduler_"$DATEVAR".out 2>&1 &
nohup sudo -u outsystems "$JAVA_HOME"/bin/jstat -gccause -t "$DEPLOYMENT" "$INTERVALMS"  > "$DIR"/jstat_deployment_"$DATEVAR".out 2>&1 &
nohup sudo -u outsystems "$JAVA_HOME"/bin/jstat -gccause -t "$LOG" "$INTERVALMS" > "$DIR"/jstat_log_"$DATEVAR".out 2>&1 &
