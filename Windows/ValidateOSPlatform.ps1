## 20-01-2016 - img (initial version)
##
## Must be executed in a computer with serverManager module installed
## Windows Server versions have this package installed by default
## For now only supports localhost validations

<#
Instructions

1. Start Powershell as Administrator
2. Change working directory to where this script is
3. Execute .\ValidateOSPlatform.ps1
#>

Param(
[Parameter(Mandatory=$True)]
[string]$ServerAddress
)

## import analyzer script
. ".\Scripts\P9_PlatformRequirementsAnalyzer.ps1" -ServerAddress $ServerAddress

## Execute validation function
StartValidation
