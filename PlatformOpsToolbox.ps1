if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$MainDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir  = Join-Path -Path $MainDir -ChildPath \MiscScripts\Windows
$ValidatorDir  = Join-Path -Path $MainDir -ChildPath \InstallationValidator\Windows
$ToolsDir  = Join-Path -Path $MainDir -ChildPath \AutomaticInstaller\Windows
$global:xExitSession=$false

function exitCode
{
  if($?) {
  Write-Host "The last command executed successfully"
  } else {
  write-host "The last command failed"
  }
}


function MainMenu
{
    param (
        [string]$Title = 'PlatformOps ToolBox'
		
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host "1: Type '1' to validate the OutSytems Platform pre-requirements on this server."
    Write-Host " "
    Write-Host "2: Type '2' to open the extra Tools Menu."
    Write-Host " "
    Write-Host "Quit: Type anything else to quit."
    Write-Host " "
	
	$selectedMain = Read-Host "Please type your selection"
	switch ($selectedMain)
	{
		1 {
			'You chose to validate the requirements described in the pre-installation block of the OutSystems Installation Checklist'
			& $ValidatorDir\installValidator.ps1

		} 2 {
			ToolsMenu
			
		} default { 
			$global:xExitSession=$true;
			    
		}
	}
}

function ToolsMenu
{
    param (
        [string]$Title = 'PlatformOps Tools Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host " If you are unsure about what these tools do, please check the ReadMe and the OutSystems Platform Installation Checklist."
    Write-Host " "
    Write-Host "1: Type 1 to disable SSLv3 in order to prevent POODLE Vulnerability "
    Write-Host " "
    Write-Host "2: Type 2 to disable FIPS Compliant Algorithms "
    Write-Host " "
    Write-Host "3: Type 3 to set ""MSMQ AlwaysWithoutDS"" to 1"
    Write-Host " "
    Write-Host "0: Type 0 to go back to the Main Menu"
    Write-Host " "
    Write-Host "Quit: Type anything else to quit."
    Write-Host " "
	
    $selectedTools = Read-Host "Please type your selection"
    switch ($selectedTools)
    {
        1 {
            'You chose to disable SSLv3'
             & regedit /s $ToolsDir\DisableSSLv3.reg
             exitCode
             pause
			 
      } 2 {
            'You chose to disable FIPS Compliant Algorithms'
             ## Were we will list the available tools and invoke them accordingly.
             & regedit /s $ToolsDir\DisableFIPS.reg
             exitCode
             pause
			 
      } 3 {
            'You chose to set ""MSMQ AlwaysWithoutDS"" to 1'
             & regedit /s $ToolsDir\SetMSMQAlwaysWithoutDS.reg
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
	& "$MainDir\PlatformOpsToolbox.ps1" #… Loop the function
	}


		
		
		
