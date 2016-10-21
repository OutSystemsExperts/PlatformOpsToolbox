#!/bin/bash
usage="
SYNOPSIS
    $(basename "$0") [-hupd] [username password outputfile] -- script to output JBoss runtime information to a file

DISCRIPTION
    Outputs the current wildfly runtime settings

OPTIONS
    -u [user], -p [password], -f [output file]

    -h  show this help text
    -u  user configured to access the JBoss Management Interface
    -p  password for the above user
    -f  can be a local directory file or a full path to a file

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

USERNAME=
PASSWORD=
FILE=
COMMAND="/core-service=platform-mbean/type=runtime/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"

while getopts ':hu:p:d:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    u) USERNAME=$OPTARG
       ;;
    p) PASSWORD=$OPTARG
       ;;
    f) DIR=$OPTARG/JBossRuntime.out
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

if [[ -z $USERNAME ]] || [[ -z $PASSWORD ]] || [[ -z $DIR ]]
then
     echo "$usage"
     exit 1
fi

# Get system current date and time
DATEVAR=$(date '+%d%m%y-%H%M')

# Load the OutSystems Variables
. /etc/sysconfig/outsystems

OUTPUT=$("$WILDFLY_HOME"/bin/jboss-cli.sh --user=$USERNAME --password=$PASSWORD --connect --command="$COMMAND" | tr '\n' ' ' | tr -d " \t\r\n")

echo '{"date"=>'$DATEVAR'},'"$date""$OUTPUT" >> "$DIR"
