
## 18-Jan-2016 - Initial version (img)
## Support for Windows Server 2008 and Windows Server 2012
## Must be updated whenever OS support for a new Windows OS is released
## Contains functions to get information about the mandatory requirements for the OutSystems Platform

## Module required for managements tasks
Import-Module ServerManager

###################################################################
## Function to check if WMI is available in the specified server ##
###################################################################
function Check_IsWMIAvailable([string]$ServerAddress) {

## Check if $ServerAddress is not empty or null
If($ServerAddress){

## Test the WMI connection
$connection = Test-Connection -Quiet -ComputerName $ServerAddress

If($connection){
    ## Return true if success. $connection value is equal to true if provided credentials work
    Return $connection

} Else {
    ## Failed to establish WMI connection, return an error mentioning that
    return 'Unable to establish WMI connection to server. Make sure that server address is correct and it has WMI enabled.'

}

} Else {
    ## Missing mandatory fields
    return 'Missing Server Address'
}
}



################################################
## Function to check if operating system version is supported
################################################
function Check_ISServerOSVersionSupported([string]$ServerAddress) {

## Check if $ServerAddress is not empty or null
If($ServerAddress){

##Store OS Version
$OSVersion = Get-WmiObject -ComputerName $ServerAddress -class Win32_OperatingSystem

##If null or empty it returned an error
if($OSVersion){
    ##Windows Server 2008
    If($OSVersion.caption -like '*Microsoft Windows Server 2008*'){

        return $True

    ##Windows Server 2012
    } ElseIf($OSVersion.caption -like '*Microsoft Windows Server 2012*'){

        return $True

    }Else{

        ##OS not suported
        return 'Unsupported Windows Server version'
    }

} Else{

    return 'Unable to get Operating System version'
}

} Else {
    ## Missing $ServerAddress fields
    return 'Missing Server Address'
}
}

################################################
## Function to check operating system version
################################################
function Check_ServerOSVersion([string]$ServerAddress) {

## Check if $ServerAddress is not empty or null
If($ServerAddress){

##Store OS Version
$OSVersion = Get-WmiObject -ComputerName $ServerAddress -class Win32_OperatingSystem

##If null or empty it returned an error
if($OSVersion){
    ##Windows Server 2008
    If($OSVersion.caption -like '*Microsoft Windows Server 2008*'){

        return '2008'

    ##Windows Server 2012
    } ElseIf($OSVersion.caption -like '*Microsoft Windows Server 2012*'){

        return '2012'

    }Else{

        ##OS not suported
        return 'Operating System not suported'
    }

} Else{

    return 'Unable to get Operating System version'
}

} Else {
    ## Missing $ServerAddress fields
    return 'Missing Server Address'
}
}


###########################################################
## function to check if .NET Framework 4.5 is already installed. Returns .NET framework version
###########################################################
function Check_NETFramework45([string]$ServerAddress){

if($ServerAddress){

##Check OSVersion
$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

##Same code for Windows Server 2008 and 2012
if($OSVersion -eq "True"){

    #Reg Key of .NET Framework 4.5
    $NET45Directory = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'

    if (Test-Path $NET45Directory) {
    #Return .NET Framework 4 version. If not installed it doesn't return anything (empty)
    ##Based on https://gist.github.com/drmohundro/40244009b2f4f32b258b
    $NETVersion = Get-ItemProperty $NET45Directory -name Version | select -expand Version
    Write-Host '.NET Framework 4.5 Version: '$NETVersion -ForegroundColor Green
} Else {

    #Returns False if not installed
    Write-Host '.NET Framework 4.5 is not installed' -ForegroundColor Red

}

} Else {
    ##unsuported windows server version/Unable to get server version
   Write-Host  $OSVersion -ForegroundColor Red
}

  }  Else {

        Write-Host 'Missing mandatory input parameters' -ForegroundColor Red

    }
    }





###########################################################
## function to check if .NET Framework 3.5 is already installed. Returns .NET framework version
###########################################################
function Check_NETFramework35([string]$ServerAddress){

if($ServerAddress){

##Check OSVersion
$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

##Same code for Windows Server 2008 and 2012
if($OSVersion -eq "True"){

    #Reg Key of .NET Framework 3.5
    $NET35Directory = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5'

    if (Test-Path $NET35Directory) {
    #Return .NET Framework 3.5 version. If not installed it doesn't return anything (empty)
    ##Based on https://gist.github.com/drmohundro/40244009b2f4f32b258b
    $NETVersion = Get-ItemProperty $NET35Directory -name Version | select -expand Version
    Write-Host '.NET Framework 3.5 Version: '$NETVersion -ForegroundColor Green
} Else {

    #Returns False if not installed
    Write-Host '.NET Framework 3.5 is not installed' -ForegroundColor Red

}

} Else {
    ##unsuported windows server version/Unable to get server version
    Write-Host  $OSVersion -ForegroundColor Red
    }
    } Else {

        Write-Host 'Missing mandatory input parameters' -ForegroundColor Red

    }
}


###########################################################
## Generic function to check OS Platform Dependencies
## Input is the WMI object name that you want to validate
###########################################################
function Check_GenericWMIQuery([string]$ServerAddress, [string]$WMIObjectName){

    $check = Get-WindowsFeature -ComputerName $ServerAddress | Where-Object {$_.Name -eq $WMIObjectName}
    return $check

}


###########################################################
## Check Application Server Role
###########################################################
function Check_RoleApplicationServer([string]$ServerAddress){

if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Application-Server"
    if($CheckInstalled.Installed){
        Write-Host 'Application Server Role is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Application Server Role is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}

}


###########################################################
## Check Application Server Role .Net Framework 3.5 Features
###########################################################
function Check_RoleApplicationServerNET35Features([string]$ServerAddress){

if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $OSDetailedVersion = Check_ServerOSVersion -ServerAddress $ServerAddress
    if($OSDetailedVersion -eq "2008"){
        $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "NET-Framework"
    if($CheckInstalled.Installed){
        Write-Host 'Application Server .NET 3.5 Framework Features is installed ' -ForegroundColor Green
    } Else {
        Write-Host 'Application Server .NET 3.5 Framework Features is not installed ' -ForegroundColor Red
    }

    }
    Elseif($OSDetailedVersion -eq "2012"){
            $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "NET-Framework-Features"
    if($CheckInstalled.Installed){
        Write-Host 'Application Server .NET 3.5 Framework Features is installed ' -ForegroundColor Green
    } Else {
        Write-Host 'Application Server .NET 3.5 Framework Features is not installed ' -ForegroundColor Red
    }
    }

} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}

}

###########################################################
## Check Web Server Role
###########################################################
function Check_RoleWebServer([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-WebServer"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Role is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Role is not installed' -ForegroundColor Red
    }


} Else {
    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Default Document
###########################################################
function Check_IISDefaultDoc([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Default-Doc"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Default Document is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Default Document is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Directory Browsing
###########################################################
function Check_IISDirBrowsing([string]$ServerAddress){
if($ServerAddress){

$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Dir-Browsing"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Directory Browsing is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Directory Browsing is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) HTTP Errors
###########################################################
function Check_IISHTTPErrors([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Http-Errors"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server HTTP Errors is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server HTTP Errors is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Static Content
###########################################################
function Check_IISStaticContent([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Static-Content"
    if($CheckInstalled.Installed){
       Write-Host 'Web Server Server Static Content is installed' -ForegroundColor Green
    } Else {
       Write-Host 'Web Server Server Static Content is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) HTTP Logging
###########################################################
function Check_IISHTTPLogging([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Http-Logging"
    if($CheckInstalled.Installed){
       Write-Host 'Web Server Server HTTP Logging is installed' -ForegroundColor Green
    } Else {
       Write-Host 'Web Server Server HTTP Logging is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Request Monitor
###########################################################
function Check_IISRequestMonitor([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Request-Monitor"
    if($CheckInstalled.Installed){
       Write-Host 'Web Server Server Request Monitor is installed' -ForegroundColor Green
    } Else {
       Write-Host 'Web Server Server Request Monitor is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Static Compression
###########################################################
function Check_IISStaticCompression([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Stat-Compression"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Static Compression is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Static Compression is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Dynamic Compression
###########################################################
function Check_IISDynamicCompression([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Dyn-Compression"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Dynamic Compression is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Dynamic Compression is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Request Filtering
###########################################################
function Check_IISRequestFiltering([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Filtering"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Web Filtering is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Web Filtering is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}


###########################################################
## Check Web Server (IIS) Windows Authentication
###########################################################
function Check_IISWindowsAuthentication([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Windows-Auth"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server Windows Authentication is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server Windows Authentication is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}


###########################################################
## Check Web Server (IIS) .NET Extensibility 3.5
###########################################################
function Check_IISNET35Extensibility([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Net-Ext"
    if($CheckInstalled.Installed){
        Write-Host 'Web Server Server .NET 3.5 Extensibility is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server .NET 3.5 Extensibility is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) .NET Extensibility 4.5
###########################################################
function Check_IISNET45Extensibility([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Net-Ext45"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server .NET 4.5 Extensibility is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server .NET 4.5 Extensibility is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) ASP .NET 3.5
###########################################################
function Check_IISASPNET35([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Asp-Net"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server ASP .NET 3.5 is installed' -ForegroundColor Green
    } Else {
        Write-Host 'Web Server Server ASP .NET 3.5 is installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) ASP .NET 4.5
###########################################################
function Check_IISASPNET45([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Asp-Net45"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server ASP .NET 4.5 is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server ASP .NET 4.5 is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) ISAPI Extensions
###########################################################
function Check_IISISAPIExt([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-ISAPI-Ext"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server .ISAPI Extensions is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server ISAPI Extensions is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) ISAPI Filters
###########################################################
function Check_IISISAPIFilter([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-ISAPI-Filter"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server ISAPI Filters is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server ISAPI Filters is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) Management Console
###########################################################
function Check_IISManagementConsole([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Mgmt-Tools"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server Management Console is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server Management Console is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check Web Server (IIS) IIS 6 Metabase Compatibility
###########################################################
function Check_IIS6Metabase([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "Web-Metabase"
    if($CheckInstalled.Installed){
         Write-Host 'Web Server Server IIS 6 Management Compability is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Web Server Server IIS 6 Management Compability is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}


###########################################################
## Check Message Queue Server
###########################################################
function Check_MSMQServer([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "MSMQ-Server"
    if($CheckInstalled.Installed){
        Write-Host 'Message Queue Server is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Message Queue Server is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}



###########################################################
## Check WAS
###########################################################
function Check_WAS([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "WAS"
    if($CheckInstalled.Installed){
        Write-Host 'Windows Process Activation Service is installed' -ForegroundColor Green
    } Else {
         Write-Host 'Windows Process Activation Service is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check WAS Process Model
###########################################################
function Check_WASProcessModel([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "WAS-Process-Model"
    if($CheckInstalled.Installed){
        Write-Host 'WAS Process Model is installed' -ForegroundColor Green
    } Else {
         Write-Host 'WAS Process Model is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check WAS .NET Environment
###########################################################
function Check_WASNETEnvironment([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "WAS-NET-Environment"
    if($CheckInstalled.Installed){
        Write-Host 'WAS .NET Environment is installed' -ForegroundColor Green
    } Else {
         Write-Host 'WAS .NET Environment is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

###########################################################
## Check WAS Configuration API
###########################################################
function Check_WASConfigAPIs([string]$ServerAddress){
if($ServerAddress){


$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

    $CheckInstalled = Check_GenericWMIQuery -ServerAddress $ServerAddress -WMIObjectName "WAS-Config-APIs"
    if($CheckInstalled.Installed){
        Write-Host 'WAS Configuration APIs is installed' -ForegroundColor Green
    } Else {
        Write-Host 'WAS Configuration APIs is not installed' -ForegroundColor Red
    }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}
}

##########################################################
## Validate AlwaysWithoutDS registry key
##########################################################
function Check_RegKeyAlwaysWithoutDS([string]$ServerAddress){
if($ServerAddress){

$OSVersion = Check_ISServerOSVersionSupported -ServerAddress $ServerAddress

if($OSVersion -eq "True"){

   ## Get reg key value
   $AlwaysWithoutDS = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\" | Select-Object -ExpandProperty "AlwaysWithoutDS"

   ## Reg key it's not null or empty(0)
   if($AlwaysWithoutDS){

   ## Recommended value
   if($AlwaysWithoutDS -eq "1"){

   Write-Host 'AlwaysWithoutDS Value:'$AlwaysWithoutDS -ForegroundColor Green

   } Else {

   Write-Host 'AlwaysWithoutDS Value:'$AlwaysWithoutDS -ForegroundColor Red

   }

   ## 0 = Empty
   } ElseIf($AlwaysWithoutDS -eq "0"){
   Write-Host 'AlwaysWithoutDS Value '$AlwaysWithoutDS -ForegroundColor Red
   ## Reg Key doesn't exist
   } Else {
    Write-Host 'AlwaysWithoutDS registry key does not exist' -ForegroundColor Red

   }


} Else {

    Write-Host  $OSVersion -ForegroundColor Red
}

} Else {

    Write-Host 'Missing mandatory parameters' -ForegroundColor Red
}


}
