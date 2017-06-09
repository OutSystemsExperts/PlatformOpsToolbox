<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER
.PARAMETER
.INPUTS
.OUTPUTS
.EXAMPLE
.EXAMPLE
.LINK
#>
param(
[string]$inputBinariesPath
)

function DevTools
{
	Param (
		[string]$title = "Development Environment Installation",
        [string]$binariesPath = $inputBinariesPath,
        [string]$devToolsPath = "C:\Program Files\OutSystems\Development Environment 10.0"
	)
	Clear-Host
    Write-Host "================ $title ================"
    Write-Host " "
    pause #Press enter to continue with the installation

    ## Find Development Tools binaries
    $developmentTools = Get-ChildItem -Path $binariesPath | Where-Object{$_.Name -like 'DevelopmentEnvironment*'}
    
    ## Missing binary
    if($developmentTools.Count -eq 0) 
    {
        Write-Host "Development Tools binary not found in the directory: $binariesPath" -ForegroundColor Red
        Write-Host " "
        Write-Host "Download Development Environment, place the binary in the directory and retry again"
        pause
    
    ## Ok to install. Just one version of the binary in the directory
    } elseif($developmentTools.Count -eq 1) 
    {
        Write-Host "Installing $developmentTools.Name"
        Write-Host " "

        ##Get installation path From XML Config File
        Try
        {
            [xml]$xmlConfigFile = [xml](Get-Content $binariesPath\"UnattendedInstallationConfigs.xml" -ErrorAction Stop)
        }
        Catch
        {
            Write-Host "Unable to open XML configuration file. Validate if the file exists at $binariesPath" -ForegroundColor Red
            pause
            exit
        }
        
        $devToolsInstallPath = $xmlConfigFile.SelectSingleNode('/Configuration/DevelopmentEnvironment/InstallPath') | % {$_.InnerText}
        
        if(!$devToolsInstallPath) 
        {
            Write-Host "Unable to find installation path configuration in the XML configuration file"
            pause
            exit
        }

        $command = $binariesPath +"\"+ $developmentTools.Name
        $args =  " /S /D=$devToolsInstallPath"
        Start-Process $command -ArgumentList $args -Wait
        
    ## Multiple versions of the binary in the directory. Which one to install
    } else {
        Write-Host "Multiple versions of Development Tools found in the directory: $binariesPath" -ForegroundColor Red
        Write-Host " "
        Write-Host "Remove unnecessary versions and retry again"
        pause
    }
}

DevTools