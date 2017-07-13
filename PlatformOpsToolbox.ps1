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

# Verify if the OutSystems Platform Server is installed
try{
    $OS = Get-ItemProperty HKLM:\SOFTWARE\OutSystems\Installer\Server -ErrorAction SilentlyContinue
}
catch{
    Write-Warning "Outsystems Platform Server is not installed on this server."
}


function MainMenu
{
    param (
        [string]$Title = 'PlatformOps ToolBox'
		
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host "1: Type '1' to access the OutSytems Platform pre-requirements menu."
    if(!$OS){
        Write-Host " "
        Write-Host "2: Type '2' to install the OutSytems Platform."
    }
    if($OS){
        Write-Host " "
        Write-Host "2: Type '2' to run system tunning for OutSytems Platform."
    }
    Write-Host " "
    Write-Host "Quit: Type anything else to quit."
    Write-Host " "
	
	$selectedMain = Read-Host "Please type your selection"
	switch ($selectedMain)
	{
		1 {
			ValidatorMenu
            
		} 2 {
			& $InstallerDir\Platform_Installer.ps1
			
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
           $PreReqDir = "C:\Users\Administrator\Desktop\PlatformOpsToolBoxBackUp\InstallationValidator\Windows"
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


		
		
		
