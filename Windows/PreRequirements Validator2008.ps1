#PowerShell script to validate Software Requirements
#21-09-2015 - Initial Version (img)
#Validate Application Server, .Net Framework 3.5, Web Server (IIS) and Message Queue Server
#22-09-2015 - Support Install of Missing Features (img)
#Validate Windows Search and Windows Managment Instrumentation (img)
#02-10-2015 - Support for remote servers (img)
#19-10-2015 - Support for Windows Server 2008 (img)

#Parameters List
Param(
  [string]$ServersList,
  [string]$Username,
  [string]$Password
)


Import-Module ServerManager

If(!$ServersList -and !$Username -and !$Password ){

$connection = Test-Connection -Quiet -ComputerName (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name

if($connection){
#Number of missing features
$countMissing = 0

#Missing features
$missingFeatures = ""

#Check If Application Server is already installed
Write-Host 'Checking if Application Server is already installed...' 
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Application-Server"}
If ($check.Installed -ne "True") {
Write-Host 'Application Server is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Application-Server`n"
}

#Check If Application Server .NETFramework dependency is already installed
Write-Host 'Checking if Application Server dependencies are already installed...'
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "AS-NET-Framework"}
If ($check.Installed -ne "True") {
Write-Host 'Application Server .NET Framework 3.5 dependency is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"AS-NET-Framework`n"
}

#Check .NET Framework 4.5.1
Write-Host 'Checking if Microsoft .NET Framework 4.5.1 is already installed...'
$check = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq "Microsoft .NET Framework 4.5.1"}
If ($check.Name -ne "Microsoft .NET Framework 4.5.1") {
Write-Host 'Microsoft .NET Framework 4.5 dependency is not installed! Download and install this dependency' -ForegroundColor Red
}

#Check If Web Server (IIS) is already installed
Write-Host 'Checking if Web Server (IIS) is already installed...'
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-WebServer"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Server`n"
}
#Check If Web Server (IIS) dependencies are already installed
Write-Host 'Checking if Web Server (IIS) dependencies are already installed...'
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Default-Doc"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Default Document feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Default-Doc`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Dir-Browsing"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Directory Browsing feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Dir-Browsing`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Http-Errors"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) HTTP Errors feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Http-Errors`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Static-Content"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Static Content feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Static-Content`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Http-Logging"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) HTTP Logging feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Http-Logging`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Request-Monitor"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Request Monitor feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Request-Monitor`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Stat-Compression"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Static Compression feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Stat-Compression`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Dyn-Compression"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Dynamic Compression feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Dyn-Compression`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Filtering"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Request Filtering feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Filtering`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Windows-Auth"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Windows Authentication feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Windows-Auth`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Net-Ext"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) .NET Extensibility 3.5 feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Net-Ext`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Asp-Net"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ASP.NET 3.5 feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Asp-Net`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-ISAPI-Ext"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ISPI Extensions feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-ISAPI-Ext`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-ISAPI-Filter"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ISAPI Filters feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-ISAPI-Filter`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Mgmt-Tools"}
If ($check.Installed -ne "True") {
Write-Host 'IIS Management Console is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Mgmt-Tools`n"
}
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Metabase"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) IIS 6 Metabase Compatibility feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Metabase`n"
}

#Check If Message Queue Server is already installed
Write-Host 'Checking if Message Queue Server is already installed...' 
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "MSMQ-Server"}
If ($check.Installed -ne "True") {
Write-Host 'Message Queue Server is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"MSMQ-Server`n"
}

#If there are missing features ask for install
if($countMissing -gt 0){
Write-Host 'You are missing ' $countMissing ' features'
$continue = "True"
$answer = Read-Host 'Want to install the missing features? (y/n)'
While($continue -eq "True"){
If($answer -eq "y" -or $answer -eq "Y"){
$content = $missingFeatures.Split("`n")
foreach ($line in $content)
{
    If($line -ne "")
    {
    Add-WindowsFeature $line
    }
}
$continue = "False"
Read-Host 'Missing features sucessfully installed. Press Enter to continue' 
}
Elseif($answer -eq "n" -or $answer -eq "N"){
Read-Host 'Be aware of the missing features. Press Enter to Continue'
$continue = "False"
}
Else{
$answer = Read-Host 'Type a valid answer (y/n)'
}

}

}
#If there's no missing features exit the validation tool 
else {Write-Host 'All required features installed!' -ForegroundColor Green
Read-Host 'Application Server and Web Server (IIS) validations complete. Press Enter to continue'
}

Write-Host 'Checking Windows Search and Windows Management Instrumentation Services'
#Validate Windows Search and Windows Management Instrumentation Services
$status = Get-Service | Where-Object {$_.Name -eq "WSearch"}
If($status.Status -eq "Running")
{
    $continue = "True"
    $answer = Read-Host 'Windows Search Service is Running. Do you want to Disable it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service WSearch -StartupType Disabled
    Stop-Service -Name WSearch
    Write-Host 'Windows Search Service successfully Disabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Search Service was left in Running' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Elseif($status.Status -eq "Stopped")
{
    $continue = "True"
    $answer = Read-Host 'Windows Search Service is Stopped however you may want to force Disabling it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service WSearch -StartupType Disabled
    Write-Host 'Windows Search Service successfully Disabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Search Service status not updated. This service may be enabled and you should manually check it' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Else
{
    Write-Host 'Windows Search Service is not installed' -ForegroundColor Green
}
$status = Get-Service | Where-Object {$_.Name -eq "Winmgmt"}
If($status.Status -eq "Stopped")
{
    $continue = "True"
    $answer = Read-Host 'Windows Management Instrumentation Service is Stopped. Do you want to Enable it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service Winmgmt -StartupType Automatic
    Start-Service -Name Winmgmt
    Write-Host 'Windows Management Instrumentation Service successfully Enabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Management Instrumentation Service was left in Stopped' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Elseif($status.Status -eq "Running")
{
    Write-Host 'Windows Management Instrumentation Service is Running' -ForegroundColor Green  
}
Else
{
    Write-Host 'Windows Management Instrumentation Service is not installed' -ForegroundColor Red  
}

Read-Host 'Windows Search and Windows Management Instrumentation services validations complete. Press Enter to continue'

} 
Else{
    Write-Host 'Windows Management Instrumentation service must be running!'
    Read-Host 'Press Enter to continue'
}
}
#Remote servers
Elseif($ServersList -and $Username -and $Password )
{
    #Impersonate domain user with permissions to validate services
    New-Object System.Management.Automation.PsCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
        $ServerNameList = $ServersList.Split(",")    foreach($servername in $ServerNameList)    {    Write-Host 'Checking Server' $servername -ForegroundColor Magenta
    $connection = Test-Connection -Quiet -ComputerName $servername

if($connection){
#Number of missing features
$countMissing = 0

#Missing features
$missingFeatures = ""

#Check If Application Server is already installed
Write-Host 'Checking if Application Server is already installed...' 
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Application-Server"}
If ($check.Installed -ne "True") {
Write-Host 'Application Server is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Application-Server`n"
}

#Check If Application Server .NETFramework dependency is already installed
Write-Host 'Checking if Application Server dependencies are already installed...'
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "AS-NET-Framework"}
If ($check.Installed -ne "True") {
Write-Host 'Application Server .NET Framework 3.5 dependency is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"AS-NET-Framework`n"
}
#Check .NET Framework 4.5.1
Write-Host 'Checking if Microsoft .NET Framework 4.5.1 is already installed...'
$check = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq "Microsoft .NET Framework 4.5.1"}
If ($check.Name -ne "Microsoft .NET Framework 4.5.1") {
Write-Host 'Microsoft .NET Framework 4.5 dependency is not installed! Download and install this dependency' -ForegroundColor Red
}

#Check If Web Server (IIS) is already installed
Write-Host 'Checking if Web Server (IIS) is already installed...'
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-WebServer"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Server`n"
}

#Check If Web Server (IIS) dependencies are already installed
Write-Host 'Checking if Web Server (IIS) dependencies are already installed...'
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Default-Doc"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Default Document feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Default-Doc`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Dir-Browsing"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Directory Browsing feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Dir-Browsing`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Http-Errors"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) HTTP Errors feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Http-Errors`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Static-Content"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Static Content feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Static-Content`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Http-Logging"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) HTTP Logging feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Http-Logging`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Request-Monitor"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Request Monitor feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Request-Monitor`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Stat-Compression"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Static Compression feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Stat-Compression`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Dyn-Compression"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Dynamic Compression feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Dyn-Compression`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Filtering"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Request Filtering feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Filtering`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Windows-Auth"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) Windows Authentication feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Windows-Auth`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Net-Ext"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) .NET Extensibility 3.5 feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Net-Ext`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Asp-Net"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ASP.NET 3.5 feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Asp-Net`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-ISAPI-Ext"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ISPI Extensions feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-ISAPI-Ext`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-ISAPI-Filter"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) ISAPI Filters feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-ISAPI-Filter`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Mgmt-Tools"}
If ($check.Installed -ne "True") {
Write-Host 'IIS Management Console is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Mgmt-Tools`n"
}
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "Web-Metabase"}
If ($check.Installed -ne "True") {
Write-Host 'Web Server (IIS) IIS 6 Metabase Compatibility feature is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"Web-Metabase`n"
}

#Check If Message Queue Server is already installed
Write-Host 'Checking if Message Queue Server is already installed...' 
$check = Get-WindowsFeature -ComputerName $servername | Where-Object {$_.Name -eq "MSMQ-Server"}
If ($check.Installed -ne "True") {
Write-Host 'Message Queue Server is not installed!' -ForegroundColor Red
$countMissing=$countMissing+1
$missingFeatures = $missingFeatures+"MSMQ-Server`n"
}

#If there are missing features ask for install
if($countMissing -gt 0){
Write-Host 'You are missing ' $countMissing ' features'
$continue = "True"
$answer = Read-Host 'Want to install the missing features? (y/n)'
While($continue -eq "True"){
If($answer -eq "y" -or $answer -eq "Y"){
$content = $missingFeatures.Split("`n")
foreach ($line in $content)
{
    If($line -ne "")
    {
    Add-WindowsFeature -ComputerName $servername $line
    }
}
$continue = "False"
Read-Host 'Missing features sucessfully installed. Press Enter to continue' 
}
Elseif($answer -eq "n" -or $answer -eq "N"){
Read-Host 'Be aware of the missing features. Press Enter to Continue'
$continue = "False"
}
Else{
$answer = Read-Host 'Type a valid answer (y/n)'
}

}

}
#If there's no missing features exit the validation tool 
else {Write-Host 'All required features installed!' -ForegroundColor Green
Read-Host 'Application Server and Web Server (IIS) validations complete. Press Enter to continue'
}

Write-Host 'Checking Windows Search and Windows Management Instrumentation Services'
#Validate Windows Search and Windows Management Instrumentation Services
$status = Get-Service -ComputerName $servername | Where-Object {$_.Name -eq "WSearch"}
If($status.Status -eq "Running")
{
    $continue = "True"
    $answer = Read-Host 'Windows Search Service is Running. Do you want to Disable it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service -ComputerName $servername WSearch -StartupType Disabled
    #Stop-Service -Name WSearch
    (Get-Service -ComputerName $servername -Name WSearch).Stop()
    Write-Host 'Windows Search Service successfully Disabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Search Service was left in Running' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Elseif($status.Status -eq "Stopped")
{
    $continue = "True"
    $answer = Read-Host 'Windows Search Service is Stopped however you may want to force Disabling it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service -ComputerName $servername WSearch -StartupType Disabled
    Write-Host 'Windows Search Service successfully Disabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Search Service status not updated. This service may be enabled and you should manually check it' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Else
{
    Write-Host 'Windows Search Service is not installed' -ForegroundColor Green
}
$status = Get-Service -ComputerName $servername | Where-Object {$_.Name -eq "Winmgmt"}
If($status.Status -eq "Stopped")
{
    $continue = "True"
    $answer = Read-Host 'Windows Management Instrumentation Service is Stopped. Do you want to Enable it? (y/n)'
    While ($continue -eq "True"){
    If($answer -eq "y" -or $answer -eq "Y"){
    Set-Service -ComputerName $servername Winmgmt -StartupType Automatic
    #Start-Service -Name Winmgmt
    (Get-Service -ComputerName $servername -Name WSearch).Start()
    Write-Host 'Windows Management Instrumentation Service successfully Enabled' -ForegroundColor Green
    $continue = "False"    
    }
    Elseif($answer -eq "n" -or $answer -eq "N"){
    Write-Host 'Windows Management Instrumentation Service was left in Stopped' -ForegroundColor Red
    $continue = "False"
    }
    Else
    { 
    $answer = Read-Host 'Type a valid answer (y/n)'
    }
    }
}
Elseif($status.Status -eq "Running")
{
    Write-Host 'Windows Management Instrumentation Service is Running' -ForegroundColor Green  
}
Else
{
    Write-Host 'Windows Management Instrumentation Service is not installed' -ForegroundColor Red  
}

Read-Host 'Windows Search and Windows Management Instrumentation services validations complete. Press Enter to continue'

}
Else{
   Write-Host 'Windows Management Instrumentation service must be running!'
   Read-Host 'Press Enter to continue'}
}
}

   
Else
{
    Write-Host 'Usage for remote servers: & ''.\PreRequirements Validator.ps1'' -ServersList "Server1,Server2,Server3" -Username "Username" -Password "Password" ' -ForegroundColor Red
 
    Write-Host 'Usage for local server: & ''.\PreRequirements Validator.ps1''' -ForegroundColor Red
    Read-Host 'Press Enter to quit'
}
