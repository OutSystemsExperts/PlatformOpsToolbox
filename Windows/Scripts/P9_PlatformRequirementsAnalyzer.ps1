## 19-Jan-2016 - Initial version (img)
## Validate the pre-requirements for OutSystems Platform


## As input the script requires the Address of the server you want to validate
Param(
[Parameter(Mandatory=$True)]
[string]$ServerAddress
)


## Import script that contains validation functions
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\P9_CheckPlatform_Functions.ps1

function StartValidation(){
## Get Execution Policy
$Policy = Get-ExecutionPolicy
Set-ExecutionPolicy $Policy


## Check if WMI is available on the remote machine
$WMIAvailable = Check_ISWMIAvailable -ServerAddress $ServerAddress
if($WMIAvailable -eq "True"){
    ## Validate .Net Framwork 3.5
   Write-Host 'Validating .NET Framework 3.5' -ForegroundColor Gray
   Check_NETFramework35 -ServerAddress $ServerAddress

   ## Validate .Net Framework 4.5
   Write-Host 'Validating .NET Framework 4.5' -ForegroundColor Gray
   Check_NETFramework45 -ServerAddress $ServerAddress

   ## Validate Application Server role
   Write-Host 'Validating Application Server role' -ForegroundColor Gray
   Check_RoleApplicationServer -ServerAddress $ServerAddress

   ## If 2012 check Application Server Role dependency
   $ServerOSVersion = Check_ServerOSVersion -ServerAddress $ServerAddress
   
   ## Check Application Server framework dependency
   Write-Host 'Validating Application Server Role .NET Framework 3.5 Features dependency' -ForegroundColor Gray
   Check_RoleApplicationServerNET35Features -ServerAddress $ServerAddress

   ## Check Web Server role
   Write-Host 'Validating Web Server Role' -ForegroundColor Gray
   Check_RoleWebServer -ServerAddress $ServerAddress
    
   ## Check IIS Default Document
   Write-Host 'Validating IIS Default Document' -ForegroundColor Gray
   Check_IISDefaultDoc -ServerAddress $ServerAddress

   ## Check IIS Directory Browsing
   Write-Host 'Validating IIS Directory Browsing' -ForegroundColor Gray
   Check_IISDirBrowsing -ServerAddress $ServerAddress

   ## Check IIS HTTP Errors   
   Write-Host 'Validating IIS HTTP Errors' -ForegroundColor Gray
   Check_IISHTTPErrors -ServerAddress $ServerAddress
   
    ## Check IIS Static Content
   Write-Host 'Validating IIS Static Content' -ForegroundColor Gray
   Check_IISStaticContent -ServerAddress $ServerAddress

    ## Check IIS HTTP Logging
   Write-Host 'Validating IIS HTTP Logging' -ForegroundColor Gray
   Check_IISHTTPLogging -ServerAddress $ServerAddress

    ## Check IIS Request Monitor
   Write-Host 'Validating IIS Request Monitor' -ForegroundColor Gray
   Check_IISRequestMonitor -ServerAddress $ServerAddress

    ## Check IIS Static Compression
   Write-Host 'Validating IIS Static Compression' -ForegroundColor Gray
   Check_IISStaticCompression -ServerAddress $ServerAddress

    ## Check IIS Dynamic Compression
   Write-Host 'Validating IIS Dynamic Compression' -ForegroundColor Gray
   Check_IISDynamicCompression -ServerAddress $ServerAddress

    ## Check IIS Request Filtering
   Write-Host 'Validating IIS Request Filtering' -ForegroundColor Gray
   Check_IISRequestFiltering -ServerAddress $ServerAddress

    ## Check IIS Windows Authentication
   Write-Host 'Validating IIS Windows Authentication' -ForegroundColor Gray
   Check_IISWindowsAuthentication -ServerAddress $ServerAddress

    ## Check IIS .NET Extensibility 3.5
   Write-Host 'Validating IIS .NET Extensibility 3.5' -ForegroundColor Gray
   Check_IISNET35Extensibility -ServerAddress $ServerAddress

    ## Check IIS .NET Extensibility 4.5
   Write-Host 'Validating IIS .NET Extensibility 4.5' -ForegroundColor Gray
   Check_IISNET45Extensibility -ServerAddress $ServerAddress
   
    ## Check IIS ASP .NET 3.5
   Write-Host 'Validating IIS ASP .NET 3.5' -ForegroundColor Gray
   Check_IISASPNET35 -ServerAddress $ServerAddress

    ## Check IIS ASP .NET 4.5
   Write-Host 'Validating IIS ASP .NET 4.5' -ForegroundColor Gray
   Check_IISASPNET45 -ServerAddress $ServerAddress

    ## Check IIS ISAPI Extensions
   Write-Host 'Validating IIS ISAPI Extensions' -ForegroundColor Gray
   Check_IISISAPIExt -ServerAddress $ServerAddress

    ## Check IIS ISAPI Filter
   Write-Host 'Validating IIS ISAPI Filter' -ForegroundColor Gray
   Check_IISISAPIFilter -ServerAddress $ServerAddress

    ## Check IIS Management Console
   Write-Host 'Validating IIS IIS Management Console' -ForegroundColor Gray
   Check_IISManagementConsole -ServerAddress $ServerAddress

    ## Check IIS 6 Metabase Compatibility
   Write-Host 'Validating IIS 6 Metabase Compatibility' -ForegroundColor Gray
   Check_IIS6Metabase -ServerAddress $ServerAddress

    ## Check Message Queueing Server
   Write-Host 'Validating Message Queue Server' -ForegroundColor Gray
   Check_MSMQServer -ServerAddress $ServerAddress

    ## Check AlwaysWithouDS registry key
   Write-Host 'Validating AlwaysWithouDS registry key value' -ForegroundColor Gray
   Check_RegKeyAlwaysWithoutDS -ServerAddress $ServerAddress

} Else {

    Write-Host $WMIAvailable
}

## Rollback Execution Policy
Set-ExecutionPolicy $Policy
}