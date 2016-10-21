#!/bin/bash
usage="
SYNOPSIS
    $(basename "$0") [-hupof] [username password collectinfo outputfile]

DESCRIPTION
    This script outputs jboss-cli information to a JSON file.
    Output options are heap, oldgen, edenspace, codecache, pssurvivorspace and threadcount

OPTIONS
    -u [user], -p [password], -o [option] -f [output file]

    -h             show this help text
    -u             is the user configured to access the JBoss Management Interface
    -p             is the password for the above user
    -o             JBoss information to collect. Can be heap, oldgen, edenspace, codecache, pssurvivorspace, threadcount
    -f             can be a local directory file or a full path to a file

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

while getopts ':hu:p:o:f:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    u) USERNAME=$OPTARG
       ;;
    p) PASSWORD=$OPTARG
       ;;
    o) OPTION=$OPTARG
       ;;
    f) FILE=$OPTARG
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


case  $OPTION  in
	heap)       
	COMMAND="/core-service=platform-mbean/type=memory/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
 	oldgen)
	COMMAND="/core-service=platform-mbean/type=memory-pool/name=PS_Old_Gen/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
	edenspace)
	COMMAND="/core-service=platform-mbean/type=memory-pool/name=PS_Eden_Space/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
	codecache)
	COMMAND="/core-service=platform-mbean/type=memory-pool/name=Code_Cache/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
	pssurvivorspace)
	COMMAND="/core-service=platform-mbean/type=memory-pool/name=PS_Survivor_Space/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
	thred-count)
	COMMAND="/core-service=platform-mbean/type=threading/:read-attribute(name=peak-thread-count,include-defaults=true)"
	;;
	class)
	COMMAND="/core-service=platform-mbean/type=class-loading/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
	gc)
	COMMAND="/core-service=platform-mbean/type=garbage-collector/:read-resource(recursive=true,proxies=true,include-runtime=true,include-defaults=true)"
	;;
esac

done

shift $((OPTIND - 1))

if [[ -z $USERNAME ]] || [[ -z $PASSWORD ]] || [[ -z $OPTION ]] || [[ -z $FILE ]]
then
     echo "$usage"
     exit 1
fi

# Get system current date and time
DATEVAR=$(date '+%d%m%y-%H%M%S')

# Load the OutSystems Variables
. /etc/sysconfig/outsystems

OUTPUT=$("$WILDFLY_HOME"/bin/jboss-cli.sh --user=$USERNAME --password=$PASSWORD --connect --command="$COMMAND" | tr '\n' ' ' | tr -d " \t\r\n")

echo '{"date"=>'$DATEVAR'},'"$date""$OUTPUT" >> "$FILE"


