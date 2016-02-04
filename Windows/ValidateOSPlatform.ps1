## 20-01-2016 - img (initial version)
##
## Must be executed in a computer with serverManager module installed
## Windows Server versions have this package installed by default

<#
Instructions

1. Start Powershell as Administrator
  1.1.  When validating a remote server your local admin account must also belong to admin group in the remote server
2. Change working directory to where this script is
3. Execute .\ValidateOSPlatform.ps1
#>

## Input parameters
Param(
[Parameter(Mandatory=$True)]
[string]$ServerAddress
)

## import analyzer script
. ".\Scripts\P9_PlatformRequirementsAnalyzer.ps1" -ServerAddress $ServerAddress

## Execute validation function
StartValidation
