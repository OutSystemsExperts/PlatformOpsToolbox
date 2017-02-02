# Description

Publish extensions and eSpaces from your local machine. Also upgrades modules still on older versions. 

OutSystems Java environments require to manually upgrade and publish each module. This batch scripts save you a lot of time, you don't have to do it by hand.

# Folder contents

- **UpgradeEspaces.bat**  
_Open, upgrade and publish all eSpaces within a folder_  

- **UpgradeExtensions.bat**  
_Open, upgrade and publish all extensions within a folder_

# Instructions

* **Create two environment variables for the Development Tools on your local machine**

**Examples:**

**Variable Name** | **Variable value**
------------ | -------------
INTEGRATIONSTUDIO | "C:\Program Files\OutSystems\Development Environment 10.0\Integration Studio\IntegrationStudio.exe"
SERVICESTUDIO | "C:\Program Files\OutSystems\Development Environment 10.0\Service Studio\ServiceStudio.exe"

* **Download and extract the solution with all modules for a local directory on your local machine.**

* **Execute the batch scripts (extensions first)**

**Examples:**   
_**Usage**_  
_UpgradeExtension.bat hostname username password "pathForExtracted Solution"_  
_UpgradeExtension.bat srvtestupgrade igoncalves outsystems "C:\Users\img\Desktop\Upgrade 10\AllModules\"_

_**Usage**_  
_UpgradeEspaces.bat hostname username password "pathForExtracted Solution"_  
_UpgradeEspaces.bat srvtestupgrade igoncalves outsystems "C:\Users\img\Desktop\Upgrade 10\AllModules\"_

This will publish extensions and eSpaces without breaking changes. Modules with breaking changes do not publish. This also dumps publishing details into the directory to where you've extracted the solution. 

# Disclaimer
*These scripts are provided AS IS without warranty of any kind from OutSystems.*  
