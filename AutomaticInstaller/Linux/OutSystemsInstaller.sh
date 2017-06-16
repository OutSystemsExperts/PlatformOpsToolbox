#!/bin/bash
## PC - OutSystems Platform Operations, June 2016
## We assume you have unrestricted access to the internet and/or repositories needed.

# Check for user privileges to run this tool as well as the configuration tool
###		1.0.1 - Expert Services - Platform Operations - 07/10/2016 : Changed the repostory URL. Now you are installing OutSystems 10.0 !
###				
if [[ $(id -u) -ne 0 ]] ;
  then echo "Please run this script as root or with an authorized sudo"
		exit 8
  else echo "You are running this script as an authorized user."
	sleep 1
fi

# Get Op System Type and version number. This will be used to define the installables path later on.
if [[ -f /usr/bin/lsb_release ]] ;
	then
		OSREL=$(lsb_release -s -i)
		OSMAJVER=$(lsb_release -s -r)
	else
		OSREL=$(cat /etc/redhat-release | cut -d' ' -f1)
		OSMAJVER=$(cat /etc/redhat-release | cut -d' ' -f3)
fi


echo "You are running on ${OSREL}, version ${OSMAJVER}."

# The full version/numbering of the OS (Redhat or CentOs) is not relevant for the dependencies. We only need to know if this is version 5, 6 or 7 of RedHat or CentOS:
OSVER=$(echo $OSMAJVER | cut -d '.' -f1)

# Now define the installables path for the TO-DO "When the customer doesn't have internet access":
echo "The installables path for your OS and Version is installables/${OSREL}/${OSVER} "
instpath=installables/${OSREL}/${OSVER}

######################################################
############# Starting Functions block ###############
######################################################

# Function Global: Check Return codes
returncode () {
case $? in
	0) echo "Task $1 completed successfully";;
	*) echo "Task $1 ended with error. Please check the output file, correct the issue and relaunch this tool"; exit 8;;
esac
}
	


# Function 1: Lets define the function that will be called later to install the dependencies.
instdep () {
for package in iptables openssh-server bash zip unzip dos2unix patch
do
	is_installed=`rpm -qa $package | wc -l`
	echo "This is now going to install the rpm for ${package} "
    if [ "$is_installed" -eq 0 ]; then
		# For now we assume that the repos needed for the packages are present and updated
		yum -y install ${package}
		returncode "Installation of ${package}"
	else
		echo "$package already present in the system."
   	fi
done   
}

# Function 2: Check if services sshd and iptables are installed and running
sshconfig () {
SSHD_INSTALLED=$(chkconfig --list sshd |  awk '{if($1 == "sshd") echo "1"}' )
case $SSHD_INSTALLED in
	0) echo "Service SSHD is not present, we'll try to configure it for you.";
		chkconfig --add sshd;
		case $? in 
			0) chkconfig sshd on;
				echo "SSHD configured\n" ;;
			*) echo "There has been an issue with the configuration of the SSHD daemon. Please refer to your System Administrator in order to sort the issue."; exit 8 ;;
		esac;;
	*) echo "SSHD is present.";
		chkconfig sshd on;
		service sshd start;;
esac
}

# Funtion 3:  Check and Configure IPTABLES Service

iptables_config () {
IPTABLES_INSTALLED=$(chkconfig --list iptables |  awk '{if($1 == "iptables") echo "1"}' )
case $IPTABLES_INSTALLED in
        0) echo "Service IPTABLES is not present, we'll try to configure it for you.";
                chkconfig --add iptables;
                case $? in
                        0) chkconfig iptables on;
                                echo "IPTABLES service configured\n" ;;
                        *) echo "There has been an issue with the configuration of the iptables service. Please refer to your System Administrator in order to sort the issue."; exit 8 ;;
                esac;;
        *) echo "IPTABLES are present.";
		chkconfig iptables on;;
esac
}

# Function 4: Configure the IPTABLES rules
iptables_rules () {
declare -A pairs=( [8081]=80 [8443]=443 )

for srcPortNumber in "${!pairs[@]}"; do
	dstPortNumber=${pairs[$srcPortNumber]}
	echo Redirecting ports $srcPortNumber to $dstPortNumber ;
	iptables -t nat -A PREROUTING -i $1 -p tcp --dport $srcPortNumber -j REDIRECT --to-port $dstPortNumber
	case $? in
		0) echo "Redirection went OK. Opening Source Ports 8081 and 8443." ;;
		*) echo "Redirection was not possible. Please check if iptables is up and running and/or system logs." ; exit 8 ;;
	esac
	echo Opening $srcPortNumber ;
	iptables -A INPUT -p tcp --dport $srcPortNumber -j ACCEPT
	case $? in
		0) echo Source port ${srcPortNumber} opened in iptables. ;;
		*) echo Issue opening source port. Check SysLogs ; exit 8 ;;
	esac
done

service iptables save
}

# Function 5 : Prepare ANT package
prepANT () {
if [ -f apache-ant-1.9.9-bin.zip ];
then
	echo "apache-ant-1.9.9-bin.zip exists in folder, will not re-download."
else
	echo "I will now download apache-ant-1.9.9-bin.zip"
	wget http://mirror.catn.com/pub/apache//ant/binaries/apache-ant-1.9.9-bin.zip
	returncode "Download of ANT"
fi
unzip -o apache-ant-1.9.9-bin.zip -d /opt/
returncode "Unzip ANT to target folder"

}

# Function 6 : Install Sun's Java JDK 8u102 and prepare environment variables
prepJDK () {
if [ -f jdk-8u121-linux-x64.rpm ];
then
	echo "jdk-8u121-linux-x64.rpm exists in folder, will not re-download."
else
	echo "I will now download jdk-8u121-linux-x64.rpm"
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm
	returncode "Download JDK from Oracle"
fi
rpm -i jdk-8u121-linux-x64.rpm ;
returncode "Installation JDK 8u121"
JAVA_HOME="/usr/java/`ls /usr/java/ | grep jdk1.8.0 | sort -t_ -n -k2 | tail -1`"
mkdir -p /usr/lib/jvm
alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 16999
alternatives --install /usr/lib/jvm/java-1.8.0 java_sdk_1.8.0 $JAVA_HOME/ 16999
returncode "Installation Java Alternatives"
alternatives --set java $JAVA_HOME/bin/java
alternatives --set java_sdk_1.8.0 $JAVA_HOME/
returncode "Setting Java Alternatives"
}

# Function 7 : Install Widlfly
instWildFly () {
if [ -f wildfly-8.2.0.Final.zip ];
then
	echo "wildfly-8.2.0.Final.zip exists in folder, will not re-download."
else
	echo "I will now download wildfly-8.2.0.Final.zip"
	wget http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.zip
fi
returncode "Download WildFly ZIP From Jboss"
unzip -o wildfly-8.2.0.Final.zip -d /opt/
returncode "Unzip WildFly to /opt/"
}


# Function 8 : Install the Outsystems repo, assuming the customer has internet access.
instoutsystems () {

isrepothere=$(yum repolist | grep -i outsystems | cut -d' ' -f1)
case $isrepothere in
	outsystems) echo "Outsystems Repository is already present.";;
	*) rpm -i http://yum.outsystems.net/10.0/noarch/outsystems-repo.rpm
		returncode "Installation Outsystems 10 Repo" ;;
esac
yum -y update
returncode "Update Yum"
yum -y install outsystems-agileplatform-wildfly8 outsystems-agileplatform outsystems-agileplatform-libs
returncode "Installation Outsystems 10 and Libs"
}

# Function 9 : Get and Extract JCE 
instJCE ()  {
if [ -f jce_policy-8.zip ];
then
	echo "jce_policy-8.zip exists in folder, will not re-download."
else
	echo "I will now download jce_policy-8.zip"
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
	returncode "Download JCE from Oracle"
fi
mv jce_policy-8.zip /opt/outsystems/platform/
returncode "Placing JCE in the target outsystems platform folder"
}

# Function 10 : Take out the trash
cleanitall () {
for downed in apache-ant-1.9.8-bin.zip jdk-8u102-linux-x64.rpm wildfly-8.2.0.Final.zip jce_policy-8.zip
do
	if [ -f $downed ];
	then
		rm -f $downed
	fi
done

}

######################################################
############# Ending Functions block ###############
######################################################



# Step 1 : install dependencies
instdep

# Step 2 : Configure the SSH Daemon
sshconfig

# Step 3 : Configure the IPTables service
iptables_config

# Step 4 : Configure the IPTables NAT rules (forwarding ports and opening traffic)
## Not needed now as this will be done by the Platform Configuration Tool
# iptables_rules

# Step 5 : Prepare ANT package
prepANT

# Step 6 : Install Sun's Java JDK and prepare environment variables
prepJDK

# Step 7 : Install Widlfly
instWildFly

# Step 8 : Install the Outsystems repo, assuming the customer has internet access.
instoutsystems

# Step 9 : Prepare the cryptography extension
instJCE

# Step 10 : clean the mess
cleanitall


### LAUNCH THE MAGIC TOOL. Have fun!
echo -e "\n
##################################################
###    Will Launch Configuration Tool now!     ###
##################################################
\n
"

/opt/outsystems/platform/configurationtool.sh
