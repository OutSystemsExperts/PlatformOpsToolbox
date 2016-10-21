#!/bin/bash
usage="
SYNOPSIS
    $(basename "$0") [-hdi] [directory interval(ms)]

DESCRIPTION
  This script gets the CPU, memory, swap and interrupt activity

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
    d) DIR=$OPTARG/vmstat
       ;;
    i) INTERVALS=$OPTARG
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

# Create script directory
/bin/mkdir -p "$DIR"

shift $((OPTIND - 1))

if [[ -z $DIR ]] || [[ -z $INTERVALS ]]
then
     echo "$usage"
     exit 1
                                                                                                                                                                                                                                                              1,6           Top
     echo "$usage"
     exit 1
fi



if ps -ef | grep -v grep | grep vmstat ; then
        exit 0
else

DATEVAR=$(date '+%d%m%y%H%M%S')
HOSTNAME=$(hostname)

OUTPUT=$(/usr/bin/vmstat -t "$INTERVALS" -S M -n > /"$DIR"/vmstat-"$HOSTNAME"-"$DATEVAR".out)
fi
