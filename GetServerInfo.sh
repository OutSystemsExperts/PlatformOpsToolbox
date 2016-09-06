#!/bin/bash

usage="$(basename "$0") [-hd] [folderpath] -- script to get server information for OutSystems Experts

where:
    -h  show this help text
    -d 	folder path to save the information"

while getopts ':hd:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    d) Dir=$OPTARG/serverinfo
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

# Create the script subfolder
/bin/mkdir -p /"$Dir"

case $option in

d)
# Kernel information, hostname and achitecture
/bin/uname -a > /"$Dir"/uname.info && echo Kernel information saved

# Mounted disk information with total and free space
/bin/df -h > /"$Dir"/disk.info && echo Disk information saved

# All physical memory information
cat /proc/meminfo > /"$Dir"/mem.info && echo Memory information saved

# All CPU information
cat /proc/cpuinfo > /"$Dir"/cpu.info && echo CPU information saved

# Is it a virtual machine ?
/usr/sbin/virt-what > /"$Dir"/virtwhat.info && echo Tenant information saved

# List all network interfaces and settings

COMMAND=$(/sbin/ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d')

for I in "$COMMAND"
do
ethtool $I > /"$Dir"/interface.info && echo Nework nterface information saved
done

# IP Configuration
/sbin/ifconfig > /"$Dir"/ip.info && echo IP configuation saved

# Route and gateway config
/bin/netstat -r > /"$Dir"/route.info && echo Route and Gateway information saved

# Find out distribution
cat /etc/redhat-release > /"$Dir"/release.info && echo Linux Release saved

# IPtables running configuration
/sbin/iptables -L > /"$Dir"/iptables.info && echo Running IPtables configuration saved

# Operating System Status
/usr/bin/yum check-update > /"$Dir"/LinuxUpdates.info && echo Yum check-updates saved

esac
done

shift $((OPTIND - 1))

if [[ -z $Dir ]]
then
     echo "$usage"
     exit 1
fi

