#!/bin/bash
#################
###	Outsystems
###	Expert Services 2016
###		Platform Operations 
###
###	Revision
###		0.1 - Paulo Costa - 26/08/2016
###				Initial version

### COLOR CODES USED
## GREEN style="color:#1E8449"
## RED style="color:#A93226"
## YELLOW style="color:#F1C40F"
## GRAY style="color:#AAB7B8"


## Initiate outputs
## TXT:
touch validator_$(hostname -s).txt
echo "" > validator_$(hostname -s).txt

### HTML Report in
HTMLREP="validator_$(hostname -s).html"

echo -e "\n\n\n\t Welcome to the OutSystems Platform installation validator.\n
  \t This will generate a "validator.html" and a "validator_$(hostname -s).txt" report file in the same folder you are running this script.
  "

echo -e "Validating your permissions.\n\n"
######### Warn user about SU/SUDO or previleges to run this script
if [[ $(id -u) -ne 0 ]] ;
  then echo "Please run this script as root or with an authorized sudo"
                exit 8
  else echo -e "You are running this script as an authorized user. \n"
        sleep 1
fi


### Start HTML page
##
### Print HTML Header
echo "<HTML>" > $HTMLREP
echo "<HEAD>" >> $HTMLREP
echo "<TITLE>" >> $HTMLREP
echo "OutSystems Platform Installation Validator" >> $HTMLREP
echo "</TITLE>" >> $HTMLREP
echo "<IMG src=https://www.google.com/a/outsystems.com/images/logo.gif align=\"right\">" >> $HTMLREP
echo "</br></br></br></br></br></br></br><H1 style=\"font-family:verdana;text-align:center\"> OutSystems Platform Installation Validator</H1>" >> $HTMLREP
echo "<P style=\"font-family:verdana;text-align:center\">For Linux Hosts and JBOSS/WildFly Application Servers.</P>" >> $HTMLREP
echo "<P style=\"font-family:verdana;text-align:center\">Validation on $(hostname -s)</P>" >> $HTMLREP
echo "</HEAD>" >> $HTMLREP
echo "<BODY>" >> $HTMLREP
echo "<table border="1" cellpadding="5" cellspacing="5" style=width:90%;font-family:verdana;font-size=90% align="center">"  >> $HTMLREP


#############################

######## Define print function
#


printhtml_single(){
echo "</br>" >> $HTMLREP
echo "<tr>" >> $HTMLREP
echo "<th bgcolor="#AAB7B8" colspan="2">$1</th>" >> $HTMLREP
echo "</tr>" >> $HTMLREP
echo "<tr>" >> $HTMLREP
echo "	<th>TEST</h>" >> $HTMLREP
echo "	<th>RESULT</th>" >> $HTMLREP
echo "</tr>" >> $HTMLREP
}



printstdout_title() {
echo "
--------------------------------------------------------------
Getting information about $1
--------------------------------------------------------------
" | tee -a validator_$(hostname -s).txt
}

printstdout() {
echo "$TESTING $RESULT" | tee -a validator_$(hostname -s).txt
}

printhtml() {
echo "<tr>" >> $HTMLREP
echo "<td>$TESTING</td>" >> $HTMLREP
echo "$RESULT2" >> $HTMLREP
echo "</tr>" >> $HTMLREP
}



############################## STEP 1 - Pre-Requirements ###################################################
printhtml_single 'Hardware Check'
printstdout_title "your server CPU" 

# Count cores
cores_count=$(grep -c ^processor /proc/cpuinfo)
TESTING="Number of CPU Cores: "
RESULT="$cores_count"
RESULT2="<td>$cores_count</td>"
printstdout
printhtml


######## Get Hardware information
# Count GB of RAM
mem_count=$(echo "scale=2; $(awk '/^MemTotal/ {print $2}' /proc/meminfo ) / 1024^2" | bc)
TESTING="Amount of RAM: "
RESULT="$mem_count GB"
RESULT2="<td>$mem_count GB</td>"
printstdout
printhtml


printhtml_single "Pre-Installation Requirements"
######## 
# Check the dependencies and warn if some is not installed
printstdout_title "required packages for the platform installation" 

for i in bash openssh-clients iptables zip unzip dos2unix patch ; do
TESTING="$i"
case $(rpm -qa $i | wc -l) in
	0)	RESULT=": Not Found. Use "yum install $i" ." 
		RESULT2="<td style="color:#A93226">Not Found. Use "yum install $i" .</td>" ;;
		
	*)	RESULT=": installed" 
		RESULT2="<td style="color:#1E8449">installed</td>"  ;; 
esac
printstdout
printhtml
done

########
# Test Iptables service
printstdout_title "the iptables service" 
TESTING="IPTables Service Running on boot?"
case $(chkconfig --list | grep iptables | grep -c "\:on" ) in
	0)	RESULT="Service Iptables is either not installed or not auto-starting.\n	Please run "chkconfig iptables on" to activate it on boot" ;
		RESULT2="<td style="color:#A93226">Service Iptables is either not installed or not auto-starting.\n	Please run "chkconfig iptables on" to activate it on boot</td>"  ;;
	*)	RESULT="Service Iptables was found and set to auto-start." ;
		RESULT2="<td style="color:#1E8449">Service Iptables was found and set to auto-start.</td>"  ;;
esac
printstdout
printhtml


########
# Test Iptables redirections
printstdout_title "iptables PREROUTING NAT table port forwarding" 
TESTING="PREROUTING NAT table port forwarding"
case $(iptables -L -vt nat | awk '!/ADDRTYPE/ && /outsystems/ && /8080|8443/' | wc -l) in
	0)	RESULT="Please check your redirections as they are not available for ports 8080 and/or 8443." ;
		RESULT2="<td style="color:#A93226">Please check your redirections as they are not available for ports 8080 and/or 8443. </td>" ;;
	1)	RESULT="Could only find one of the two expected rules. Please re-check your port forwarding via iptables." ;
		RESULT2="<td style="color:#A93226">Could only find one of the two expected rules. Please re-check your port forwarding via iptables.</td>" ;;
	2)	RESULT="Both expected rules were found."  ;
		RESULT2="<td style="color:#1E8449">Both expected rules were found.</td>"  ;;
esac
printstdout
printhtml

########
# Check if ANT is present
printstdout_title "apache-ant installation" 
TESTING="ANT Installation and path"
case $(find /opt/*/bin -name "ant" -type f -print | wc -l) in
	1)	RESULT="Ant found in expeted path" ;
		RESULT2="<td style="color:#1E8449">Ant found in expected path" ;;
	*)	RESULT="Could not find ANT in the expected path. Re-check if you have Apache Ant extracted to /opt "  ;
		RESULT2="<td style="color:#F1C40F">Could not find ANT in the expected path. Re-check if you have Apache Ant extracted to /opt</td>"  ;
esac
printstdout
printhtml

############################## STEP 2 - OutSystems Packages ###################################################

printhtml_single "OutSystems Packages Installation"
printstdout_title "OutSystems Packages Installation"

### Test how many outsystems RPM are installed. 

REPO=$(rpm -qa outsystems-repo* | wc -l)
TESTING="OutSystems Repository on local RPMDB"
case $REPO in
	0)	RESULT="Cannot find OutSystems Repository in your local RPMDB"
		RESULT2="<td style="color:#F1C40F">Cannot find OutSystems Repository in your local RPMDB</td>";;
	1) 	RESULT="OutSystems Repository is present"
		RESULT2="<td style="color:#1E8449">OutSystems Repository is present</td>";;
esac
printstdout
printhtml


LIBS=$(rpm -qa outsystems-agileplatform*libs* | wc -l)
TESTING="OutSystems Platform Libraries"
case $LIBS in
	0)	RESULT="Cannot find OutSystems Libraries installation"
		RESULT2="<td style="color:#A93226">Cannot find OutSystems Libraries installation</td>";;
	1) 	RESULT="OutSystems Platform Libraries are present"
		RESULT2="<td style="color:#1E8449">OutSystems Platform Libraries are present</td>";;
esac
printstdout
printhtml


AS=$(rpm -qa outsystems-agileplatform*jboss*||outsystems-agileplatform*wildfly*| wc-l)
TESTING="Application Server"
case $LIBS in
	0)	RESULT="Cannot find the Application Server installation"
		RESULT2="<td style="color:#A93226">Cannot find the Application Server installation</td>";;
	1) 	RESULT="Application Server RPM is installed"
		RESULT2="<td style="color:#1E8449">Application Server RPM is installed</td>";;
esac
printstdout
printhtml

PLAT=$(rpm -qa outsystems-agileplatform | wc -l)
TESTING="OutSystems Platform Server"
case $LIBS in
	0)	RESULT="Cannot find the OutSystems Platform Server installation"
		RESULT2="<td style="color:#A93226">Cannot find the OutSystems Platform Server installation</td>";;
	1) 	RESULT="OutSystems Platform Server is installed"
		RESULT2="<td style="color:#1E8449">OutSystems Platform Server is installed</td>";;
esac
printstdout
printhtml

############################## STEP 3 - OutSystems Services Checkup ###################################################

printhtml_single "OutSystems Service start on server initialization"
printstdout_title "OutSystems Service start on server initialization"

## check for the <application.server>-outsystems
AS_SERV=$(chkconfig --list | awk '/-outsystems\t/ && /:on/' | wc -l)
TESTING="Application Server Service starts on boot?"
case $AS_SERV in
	0)	RESULT="Cannot find the Application Server service configuration on boot"
		RESULT2="<td style="color:#A93226">Cannot find the Application Server Service configuration on boot</td>";;
	1) 	RESULT="Yes"
		RESULT2="<td style="color:#1E8449">Yes</td>";;
esac
printstdout
printhtml


## check for the <application.server>-outsystems-mq
MQ_AS_SERV=$(chkconfig --list | awk '/-outsystems-mq\t/ && /:on/' | wc -l)
TESTING="MQ Service starts on boot?"
case $MQ_AS_SERV in
	0)	RESULT="Cannot find the MQ Service configuration on boot"
		RESULT2="<td style="color:#A93226">Cannot find the MQ Service configuration on boot</td>";;
	1) 	RESULT="Yes"
		RESULT2="<td style="color:#1E8449">Yes</td>";;
esac
printstdout
printhtml


## Check for the outsystems platform service
OS_SERV=$(chkconfig --list | awk '/^outsystems/ && /:on/' | wc -l)
TESTING="OutSystems Platform Server Service start on boot?"
case $OS_SERV in
	0)	RESULT="Cannot find the OutSystems service configuration on boot"
		RESULT2="<td style="color:#A93226">Cannot find the OutSystems Platform Server Service configuration on boot</td>";;
	1) 	RESULT="Yes"
		RESULT2="<td style="color:#1E8449">Yes</td>";;
esac
printstdout
printhtml

#### Check for the jce_policy file

TESTING="Check for jce_policy presence in the outsystems folder"
if [ ! -f /opt/outsystems/jce_policy* ]; then
		RESULT="Cannot find the Oracle jce_policy file. Please repeat the download step from the installation checklist."
		RESULT2="<td style="color:#A93226">Cannot find the Oracle jce_policy file. Please repeat the download step from the installation checklist.</td>"
	else
		RESULT="File found"
		RESULT2="<td style="color:#1E8449">File Found</td>"
fi

## Check if this is a controller or FE
### If the CompilerServerHostname is defined to localhost, 127.0.0.1, `hostname -i` or `hostname -s`, then the CONTROLLER service in should be ENABLED.
TESTING="OutSystems Platform Server Depoloyment Controller Configuration."

### Option A was to define the possibilities as variables
##### Opted to ask directly in the case.
#compiler_value=$(awk -F '[<>]' '/CompilerServerHostname/{print $3}' /etc/outsystems/server.hsconf )
#shorthost=$(hostname -s)
#hostip=$(hostname -i)
#controller_enabled=$(grep -c -w CONTROLLER=\"ENABLED\" /etc/outsystems/os.services.conf)

case $(awk -F '[<>]' '/CompilerServerHostname/{print $3}' /etc/outsystems/server.hsconf ) in
	"localhost"|"127.0.0.1"|$(hostname -s)|$(hostname -i) ) 
		if [[ $(grep -c -w CONTROLLER=\"ENABLED\" /etc/outsystems/os.services.conf) -eq 1 ]]; then
			RESULT="Server has the Deployment Controller Role and has a correct configuration."
			RESULT2="<td style="color:#1E8449">Server has the Deployment Controller Role and has a correct configuration.</td>"
		else
			RESULT="Server has the Deployment Controller Role BUT is NOT correctly configured."
			RESULT2="<td style="color:#A93226">Server has the Deployment Controller Role BUT is NOT correctly configured.</td>"
		fi
		;;
	* ) RESULT="Server has a Front-End Role but NOT the Deployment Controller Role"
		RESULT2="<td style="color:#1E8449">Server has a Front-End Role but NOT the Deployment Controller Role</td>"
		;;
esac
printstdout
printhtml

############################## STEP 4 - Check some user variables ###################################################

printhtml_single "Check for user variables and paths"
printstdout_title "Check for user variables and paths"
TESTING="Checking limit of inotify instances"
if [ "$(cat /proc/sys/fs/inotify/max_user_instances)" -lt "1024" ]; then
		RESULT="Low limit detected. Edit /etc/sysctl.conf and add/replace this line: fs.inotify.max_user_instances=1024"
		RESULT2="<td style="color:#F1C40F">Low limit detected. Edit /etc/sysctl.conf and add/replace this line: fs.inotify.max_user_instances=1024</td>"
	else
		RESULT="Limit equal or greater than 1024"
		RESULT2="<td style="color:#1E8449">Limit equal or greater than 1024</td>"
fi
printstdout
printhtml

### Variables
for i in $(cat /etc/sysconfig/outsystems | awk -F\= '{print $1}' | grep -v SUCOMMAND); do
	TESTING="Checking if path for $i exists."
	if [ -d $(grep $i /etc/sysconfig/outsystems | awk -F\= '{print $2}' ) ]; then
			RESULT="Path exists."
			RESULT2="<td style="color:#1E8449">Path exists.</td>"
			printstdout
			printhtml
		else
			RESULT="Path not found. Please re-check all requirements from the OutSystems Installation Checklist."
			RESULT2="<td style="color:#A93226">Path not found. Please re-check all requirements from the OutSystems Installation Checklist.</td>"
			printstdout
			printhtml
	fi
done

#### Testing Service Center Reachability (locally)
printhtml_single "Check for HTTP access to the Service Center"
printstdout_title "Check for HTTP access to the Service Center"
TESTING="Is Service Center reachable?"
case $(curl --silent localhost/ServiceCenter/_ping.jsf | grep -c running) in
	1 ) RESULT="Reachable on localhost/ServiceCenter"
		RESULT2="<td style="color:#1E8449">Reachable on localhost/ServiceCenter</td>"
		
		;;
	*)	RESULT="NOT Reachable on localhost/ServiceCenter"
		RESULT2="<td style="color:#A93226">NOT Reachable on localhost/ServiceCenter</td>"
		;;
esac
printstdout
printhtml

### Stop HTML page
##
echo "</table>
</BODY>" >> $HTMLREP