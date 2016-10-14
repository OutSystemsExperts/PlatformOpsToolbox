# Parameter computer name
Param(
[string]$ComputerName
)

$title = "OutSystems Version"
$message = "Please select the version of OutSystems installation you are validating the requirements for"


$one = New-Object System.Management.Automation.Host.ChoiceDescription "&10", `
    "Version 10"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&9.1", `
    "Version 9.1"
    

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {$PlatformVersion = "10" ; "You selected version 10" } 
        1 {$PlatformVersion = "9.1" ; "You selected version 9.1"}
    }
	
write-host $PlatformVersion
	
# Auxiliary variables
$minimumRAM = 4
$minimumCPUCores = 2



# If computer name is not provided use localhost
if(!$ComputerName)
{
  #Set ComputerName variable to localhost
  $ComputerName = "localhost" 
}

# Validate if WMI is available
$wmiConnection = Test-Connection -Quiet -ComputerName $ComputerName

# WMI is available
if($wmiConnection -eq "True")
{
Write-Host "Validating Hardware requirements."

############
# Hardware #
############
# Validate hardware minimum requirements first
$hardwareSpecs = Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName
$processors = get-wmiobject win32_processor
$cores = @($processors).count * @($processors)[0].NumberOfCores

# Validate number of CPU Cores
Write-Host "Validating hardware minimum requirements" -ForegroundColor Gray 


#if( $coresl  -lt $minimumCPUCores)
if($hardwareSpecs.NumberOfLogicalProcessors -lt $minimumCPUCores)
{
  Write-Host "Number of CPU cores doesn't meet the minimum requirements" -ForegroundColor Red

}  
else
{
  Write-Host "CPU meets the minimum requirements" -ForegroundColor Green 
}

# Validate physical memory
if($("{0:F0}" -f $($hardwareSpecs.TotalPhysicalMemory/1GB)) -lt $minimumRAM)
{
  Write-Host "Available RAM memory doesn't meet the minimum requirements"`n"" -ForegroundColor Red

}
else
{
  Write-Host "Available RAM memory meets the minimum requirements"`n"" -ForegroundColor Green 
}

############
# Software #
############
# Validate software requirements

# First thing to validate is Operating System version
$OSVersion = Get-WmiObject -ComputerName $ComputerName -class Win32_OperatingSystem

# Windows Server 2008
If($OSVersion.caption -like "*Microsoft Windows Server 2008*" )
{
  $OSVersion = "2008"
 ##Windows Server 2012
}
# Windows Server 2012
ElseIf($OSVersion.caption -like "*Microsoft Windows Server 2012*" )
{
  $OSVersion = "2012"
}
# Unsupported Windows Server version
Else
{
  $OSVersion = "Unsupported Windows Server version"
}

#Supported Windows Server version - 2008 or 2012
if($OSVersion -eq "2008" -or $OSVersion -eq "2012")
{
  Write-Host "Validating Software requirements."

  # Validate software pre-requirements
  # .NET Framework 3.5
  Write-Host "Validating .NET Framework 3.5" -ForegroundColor Gray  
  # If not installed it doesn't return anything 
  $NET35Version = Invoke-Command -ComputerName $ComputerName {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" -name Version | select -expand Version}

  # If $NET35Version has a value it means .NET Framework 3.5 is installed
  if($NET35Version)
  {
    Write-Host ".NET Framework 3.5 version : "$NET35Version "`n" -ForegroundColor Green 
  }
  else{
    Write-Host ".NET Framework 3.5 is not installed" "`n" -ForegroundColor Red  
  } 

  # .NET Framework 4.5
  Write-Host "Validating .NET Framework 4.5" -ForegroundColor Gray  
  # If not installed it doesn't return anything
  $NET45Version = Invoke-Command -ComputerName $ComputerName {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -name Version | select -expand Version}

  # If $NET45Version has a value it means .NET Framework 4.5 is installed
  if($NET45Version)
  {
    Write-Host ".NET Framework 4.5 version : "$NET45Version "`n" -ForegroundColor Green
  }
  else{
    Write-Host ".NET Framework 4.5 is not installed" "`n" -ForegroundColor Red  
  }



  if ($PlatformVersion -eq "10" )
  {
    Write-Host "Validating .NET Framework 4.6" -ForegroundColor Gray  
    $NET46Version = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
    Get-ItemProperty -name Version,Release -EA 0 |
    Where { $_.PSChildName -match '^(?!S)\p{L}'} |
    Select PSChildName, Version, Release, @{
      name="Product"
      expression={
        switch -regex ($_.Release) {
          "378675|378758" { [Version]"4.5.1" }
          "379893" { [Version]"4.5.2" }
          "393295|393297" { [Version]"4.6" }
          "394254|394271" { [Version]"4.6.1" }
          "394802|394806" { [Version]"4.6.2" }
          {$_ -gt 394806} { [Version]"Undocumented 4.6.2 or higher, please update script" }
        }
      }
    }
 
    if ($NET46Version -Match "4.6.1" -or $NET46Version -Match "4.6.2")
    {
        write-host ".NET Framework 4.6.1 version or superior is installed" "`n" -ForegroundColor Green
    }
    else
    { 
        write-host ".NET Framework 4.6.1 version or superior is not installed" "`n" -ForegroundColor Red  
    }
  }
  

  # Application Server role (Windows Features)
  Write-Host "Validating Application Server role" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Application-Server"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Application Server Role is installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Application Server Role is not installed" "`n" -ForegroundColor Red  
  }

  # .NET Framework 3.5 dependency - WMI onject name depends on OS version
  Write-Host "Validating Application Server Role .NET Framework 3.5 Features dependency" -ForegroundColor Gray  
  if($OSVersion -eq "2008")
  {
    $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "NET-Framework"}
    if($CheckInstalled.Installed)
    {
      Write-Host "Application Server .NET 3.5 Framework Features is installed" "`n" -ForegroundColor Green
    } 
    Else
    {
      Write-Host "Application Server .NET 3.5 Framework Features is not installed" "`n" -ForegroundColor Red  
    }
  }
  Elseif($OSVersion -eq "2012")
  {
    $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "NET-Framework-Features"}
    if($CheckInstalled.Installed)
    {
      Write-Host "Application Server .NET 3.5 Framework Features is installed" "`n" -ForegroundColor Green
    }
    Else
    {
      Write-Host "Application Server .NET 3.5 Framework Features is not installed" "`n" -ForegroundColor Red  
    }
  }

  # Web Server role
  Write-Host "Validating Web Server Role" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-WebServer"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Role is installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Role is not installed" "`n" -ForegroundColor Red  
  }

  # IIS feature Default Document
  Write-Host "Validating IIS Default Document" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Default-Doc"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Default Document is installed" "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Default Document is not installed" "`n" -ForegroundColor Red  
  }

  # IIS featue Directory Browsing
  Write-Host "Validating IIS Directory Browsing" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Dir-Browsing"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Directory Browsing is installed" "`n"  -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Directory Browsing is not installed" "`n" -ForegroundColor Red
  }

  # IIS feature HTTP Errors
  Write-Host "Validating IIS HTTP Errors" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Http-Errors"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server HTTP Errors is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server HTTP Errors is not installed `n" -ForegroundColor Red  
  }

  # IIS feature Static Content
  Write-Host "Validating IIS Static Content" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Static-Content"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Static Content is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Static Content is not installed `n" -ForegroundColor Red  
  }

  # IIS feature HTTP Logging
  Write-Host "Validating IIS HTTP Logging" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Http-Logging"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server HTTP Logging is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server HTTP Logging is not installed `n" -ForegroundColor Red  
  }

  # IIS feature Request Monitor
  Write-Host "Validating IIS Request Monitor" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Request-Monitor"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Request Monitor is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Request Monitor is not installed `n" -ForegroundColor Red  
  }

  # IIS feature Static Compression
  Write-Host "Validating IIS Static Compression" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Stat-Compression"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Static Compression is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Static Compression is not installed `n" -ForegroundColor Red  
  }

  # IIS feature Dynamic Compression
  Write-Host "Validating IIS Dynamic Compression" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Dyn-Compression"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Dynamic Compression is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Dynamic Compression is not installed `n" -ForegroundColor Red  
  }

  # IIS feature Request Filtering
  Write-Host "Validating IIS Request Filtering" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Filtering"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Web Filtering is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Web Filtering is not installed `n" -ForegroundColor Red  
  }

  # IIS Windows Authentication
  Write-Host "Validating IIS Windows Authentication" -ForegroundColor Gray  
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Windows-Auth"}
  if($CheckInstalled.Installed)
  {
    Write-Host "Web Server Server Windows Authentication is installed `n" -ForegroundColor Green
  }
  Else
  {
    Write-Host "Web Server Server Windows Authentication is not installed `n" -ForegroundColor Red
  }

  # IIS feature .NET Extensibility 3.5
  Write-Host "Validating IIS .NET Extensibility 3.5" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Net-Ext"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server .NET 3.5 Extensibility is installed' "`n" -ForegroundColor Green | tee-object –FilePath "c:\temp\teste2.htm"
  }
  Else
  {
    Write-Host 'Web Server Server .NET 3.5 Extensibility is not installed' "`n" -ForegroundColor Red
  }

  # IIS feature .NET Extensibility 4.5
  Write-Host "Validating IIS .NET Extensibility 4.5" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Net-Ext45"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server .NET 4.5 Extensibility is installed' "`n" -ForegroundColor Green | tee-object –FilePath "c:\temp\teste2.htm"
  }
  Else
  {
    Write-Host 'Web Server Server .NET 4.5 Extensibility is not installed' "`n" -ForegroundColor Red
  }

  # IIS feature ASP .NET 3.5
  Write-Host "Validating IIS ASP .NET 3.5" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Asp-Net"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server ASP .NET 3.5 is installed' "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'Web Server Server ASP .NET 3.5 is installed' "`n" -ForegroundColor Red
  }

  # IIS feature ASP .NET 4.5
  Write-Host "Validating IIS ASP .NET 4.5" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Asp-Net45"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server ASP .NET 4.5 is installed' "`n" -ForegroundColor Green 
  }
  Else
  {
    Write-Host 'Web Server Server ASP .NET 4.5 is installed' "`n" -ForegroundColor Red
  }

  # IIS feature ISAPI Extensions
  Write-Host "Validating IIS ISAPI Extensions" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-ISAPI-Ext"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server .ISAPI Extensions is installed' "`n" -ForegroundColor Green 
  }
  Else
  {
    Write-Host 'Web Server Server ISAPI Extensions is not installed' "`n" -ForegroundColor Red
  }

  # IIS ISAPI Filter
  Write-Host "Validating IIS ISAPI Filter" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-ISAPI-Filter"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server ISAPI Filters is installed' "`n" -ForegroundColor Green 
  }
  Else
  {
    Write-Host 'Web Server Server ISAPI Filters is not installed' "`n" -ForegroundColor Red
  }

  # IIS feature Management Console
  Write-Host "Validating IIS IIS Management Console" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Mgmt-Tools"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server Management Console is installed' "`n" -ForegroundColor Green 
  }Else
  {
    Write-Host 'Web Server Server Management Console is not installed' "`n" -ForegroundColor Red
  }

  # IIS feature Metabase Compatibility
  Write-Host "Validating IIS 6 Metabase Compatibility" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "Web-Metabase"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Web Server Server IIS 6 Management Compability is installed' "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'Web Server Server IIS 6 Management Compability is not installed' "`n" -ForegroundColor Red
  }

  # WAS process model
  Write-Host "Validating WAS Process Model" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "WAS-Process-Model"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'WAS Process Model is installed'  "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'WAS Process Model is not installed' "`n" -ForegroundColor Red
  }

  # WAS .NET Environment
  Write-Host "Validating WAS .NET Environment" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "WAS-NET-Environment"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'WAS .NET Environment is installed' "`n" -ForegroundColor Green 
  }
  Else
  {
    Write-Host 'WAS .NET Environment is not installed'  "`n" -ForegroundColor Red
  }

  # WAS Configuration APIs
  Write-Host "Validating WAS Configuration APIs " -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "WAS-Config-APIs"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'WAS Configuration APIs is installed' "`n" -ForegroundColor Green 
  }
  Else
  {
    Write-Host 'WAS Configuration APIs is not installed' -ForegroundColor Red
  }
  
  # Message queue server
  Write-Host "Validating Message Queue Server" -ForegroundColor Gray
  $CheckInstalled = Get-WindowsFeature -ComputerName $ComputerName | Where-Object {$_.Name -eq "MSMQ-Server"}
  if($CheckInstalled.Installed)
  {
    Write-Host 'Message Queue Server is installed' "`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'Message Queue Server is not installed' "`n" -ForegroundColor Red
  }


  # Confirm that FIPS Compliant Algorithms are disabled
  Write-Host "Validating that FIPS Compliant Algorithms are disabled" -ForegroundColor Gray
  $FIPS = Invoke-Command -ComputerName $ComputerName {Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\" | Select-Object -ExpandProperty "Enabled"}
  # Recommended value = 0
  if($FIPS -eq "0")
  {
    Write-Host 'FIPS Compliant Algorithms are disabled'"`n" -ForegroundColor Green
  }
  Else
  {
    Write-Host 'FIPS Compliant Algorithms are still enabled'"`n" -ForegroundColor Red
  }



  # Message queue server reg Key to never use domain controller servers
  Write-Host "Validating AlwaysWithouDS registry key value" -ForegroundColor Gray
  $AlwaysWithoutDS = Invoke-Command -ComputerName $ComputerName {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters\Setup\" | Select-Object -ExpandProperty "AlwaysWithoutDS"}

  # Reg key it's not null or empty(0)
  if($AlwaysWithoutDS)
  {

    # Recommended value
    if($AlwaysWithoutDS -eq "1")
    {
      Write-Host 'AlwaysWithoutDS Value is correct:'$AlwaysWithoutDS -ForegroundColor Green
    }
    Else
    {
      Write-Host 'AlwaysWithoutDS Value is not correct:'$AlwaysWithoutDS -ForegroundColor Red
    }
  # 0 = Empty
  }
  ElseIf($AlwaysWithoutDS -eq "0")
  {
    Write-Host 'AlwaysWithoutDS Value '$AlwaysWithoutDS  "`n"-ForegroundColor Red
  # Reg Key doesn't exist
  }
  Else
  {
    Write-Host 'AlwaysWithoutDS registry key does not exist' "`n" -ForegroundColor Red
  }

}

# Unsupported Windows Server version
else
{
  Write-Host "Unsupported Windows Server version"
}
}
# WMI is not available
else
{
  Write-Host "Unable to establish WMI connection to server. Make sure that computer name is correct and it has WMI enabled."
}
Read-Host -Prompt 'Press any key to exit the validator and close this window'
