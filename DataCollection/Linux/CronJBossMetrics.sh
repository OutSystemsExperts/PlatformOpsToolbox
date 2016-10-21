#!/bin/bash

if ps -ef | grep -v grep | grep GetJBossMetrics ; then
        exit 0
else

USERNAME=$1
PASSWORD=$2
SCRIPTDIR=$3
DIR=$4

"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o heap 	-f "$DIR"/heap.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o oldgen	-f "$DIR"/oldgen.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o edenspace	-f "$DIR"/edenspace.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o codecache	-f "$DIR"/codecache.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o pssurvivorspace	-f "$DIR"/pssurvivorspace.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o thred-count	-f "$DIR"/thred-count
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o class	-f "$DIR"/class.out
"$SCRIPTDIR"/GetJBossMetrics.sh -u "$USERNAME" -p "$PASSWORD" -o gc	-f "$DIR"/gc.out

fi
