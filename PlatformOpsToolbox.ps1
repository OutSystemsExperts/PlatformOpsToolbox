if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$MainDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir  = Join-Path -Path $MainDir -ChildPath \MiscScripts\Windows
$PreReqDir  = Join-Path -Path $MainDir -ChildPath \InstallationValidator\Windows
$InstallerDir  = Join-Path -Path $MainDir -ChildPath \AutomaticInstaller\Windows
$global:xExitSession=$false

function exitCode
{
  if($?) {
  Write-Host "The last command executed successfully"
  } else {
  write-host "The last command failed"
  }
}

$OSisInstalled = $false


function MainMenu
{
    param (
        [string]$Title = 'PlatformOps ToolBox'
		
    )

    Clear-Host
    ##if($OSisInstalled -eq $True){
     ##   Write-Host "OutSystems Platform is already installed."
   # }    
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host "1: Type '1' to access the OutSytems Platform pre-requirements menu."
    Write-Host " "
    Write-Host "2: Type '2' to install the OutSytems Platform."
    Write-Host " "
    Write-Host "3: Type '3' to run system tunning for OutSytems Platform."
    Write-Host " "
    Write-Host "Quit: Type anything else to quit."
    Write-Host " "
	
	$selectedMain = Read-Host "Please type your selection"
	switch ($selectedMain)
	{
		1 {
			ValidatorMenu
            
		} 2 {

            # Verify if the OutSystems Platform Server is installed
            
           # $OS = Get-ItemProperty HKLM:\SOFTWARE\OutSystems\Installer\Server -ErrorAction SilentlyContinue
            #if($OS -eq $null){
                & $InstallerDir\Platform_Installer.ps1
            ##}else{
               # $OSisInstalled = $True
           ## }			
		
        } 3 {
			& $InstallerDir\OutSystems_Platform_Tunning.ps1
			
		} default { 
			$global:xExitSession=$true;
			    
		}
	}
}

function ValidatorMenu
{
    param (
        [string]$Title = 'OutSystems Platform Pre-Requirements Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host "1: Type 1 to validate OutSystems Platform Pre-Requirements on this server"
    Write-Host " "
    Write-Host "2: Type 2 to install OutSystems Platform Pre-Requirements"
    Write-Host " "
    Write-Host "0: Type 0 to go back to the Main Menu"
    Write-Host " "
    Write-Host "Quit: Type anything else to quit."
    Write-Host " "
	
    $selectedTools = Read-Host "Please type your selection"
    switch ($selectedTools)
    {
        1 {
            'You chose OutSystems Platform Pre-Requirements validation'
             & $PreReqDir\Installation_Validator.ps1
             exitCode
             pause
			 
      } 2 {
            'You chose OutSystems Platform Pre-Requirements installation'
             & $PreReqDir\Pre-Requirements_Installator.ps1 -ScriptPath  $MainDir
             exitCode
             pause
			 
      } 0 {
             
      } default { 
			 $global:xExitSession=$true;
		}
    }

}

		
MainMenu
If ($xExitSession){
	exit
}else{
	& "$MainDir\PlatformOpsToolbox.ps1" #â€¦ Loop the function
	}


		
		