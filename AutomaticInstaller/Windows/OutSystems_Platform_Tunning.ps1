#----OutSystems Platform Tunning----
#--------------------------

#Set-ExecutionPolicy RemoteSigned -ErrorAction SilentlyContinue

#-----------------------------------
# Verify if OutSystems Platform is installed
$OSPathReg = "HKLM:\SOFTWARE\OutSystems\Installer\Server"

if(Test-Path $OSPathReg -pathType container){


    Import-Module WebAdministration

    #navigate to the app pools root
    cd IIS:\AppPools\

    Write-Host "Tunning Service Center Application Pool" "`n"

    #----Tune Service Center Application Pool----
    #-------------------------


    #check if the application pool doesn't exists
    if (!(Test-Path "ServiceCenterAppPool" -pathType container)){
            
        #create the app pool
        $appPool = New-Item "ServiceCenterAppPool"  
        
    }else{
        $appPool = Get-Item "ServiceCenterAppPool"
    }

    #Configure the Service Center Application Pool
    $appPool.managedRuntimeVersion = "v4.0"
    $appPool.managedPipelineMode = "Classic"
                
    #Uncheck all checkboxes under Fixed Intervals group
    $appPool.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
    $appPool.recycling.periodicRestart.requests = 0
                
    #Remove the Private memory limit usage.
    $appPool.recycling.periodicRestart.privateMemory = 0
             
    #Activate all the Runtime recycling events
    $appPool.recycling.logEventOnRecycle = "ConfigChange,IsapiUnhealthy,OnDemand" 
                
    #Disable Rapid Failover
    $appPool.failure.rapidFailProtection = "false"
    $appPool.processModel.idleTimeout =  [TimeSpan]::FromMinutes(0)

    $appPool | Set-Item 

    #Verify if Service Center application is installed
    $site = Get-WebApplication -Site "Default Web Site"

    if($site.path -match "ServiceCenter"){
        #Move application to ServiceCenterAppPool
        Set-ItemProperty 'IIS:\Sites\Default Web Site\ServiceCenter' applicationPool ServiceCenterAppPool
    }

    Write-Host "Service Center Application Pool Tunning Complete" "`n" -ForegroundColor Green




    #----Tune Lifetime Application Pool----
    #--------------------------------------
     
    Write-Host "Tunning Lifetime Application Pool" "`n"

    #Check if LifeTime was installed
    if($site.path -match "LifeTime"){

        #check if the application pool doesn't exists
        if (!(Test-Path "LifeTimeAppPool" -pathType container)){
            
            #create the app pool
            $appPool = New-Item "LifeTimeAppPool"  
                
        }else{
            $appPool = Get-Item "LifeTimeAppPool"
        }

        #Configure the LifeTime Application Pool
        $appPool.managedRuntimeVersion = "v4.0"
        $appPool.managedPipelineMode = "Classic"
                
        #Uncheck all checkboxes under Fixed Intervals group
        $appPool.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
        $appPool.recycling.periodicRestart.requests = 0
                
        #Limit the Private memory usage to be at most 60% of the total physical memory of the machine.
        $SysMemory = Get-WmiObject -class "Win32_PhysicalMemoryArray"
        $appPool.recycling.periodicRestart.privateMemory = [int]($SysMemory.MaxCapacity * 0.6)
             
        #Activate all the Runtime recycling events
        $appPool.recycling.logEventOnRecycle = "ConfigChange,IsapiUnhealthy,OnDemand" 
                
        #Disable Rapid Failover
        $appPool.failure.rapidFailProtection = "false"
        $appPool.processModel.idleTimeout =  [TimeSpan]::FromMinutes(0)

        $appPool | Set-Item 

        #Verify if exists any LifeTime application
        foreach($app in $site){
        
            if($app.path -match "LifeTime"){
            #If exists any LifeTime application move it to LifeTimeAppPool
                
                #Move application to LifeTimeAppPool
                $Path = 'IIS:\Sites\Default Web Site' + $app.Path
                Set-ItemProperty $Path applicationPool LifeTimeAppPool
            }
        }

        if ($site.path -match "PerformanceMonitor"){
            
            #Move PerformanceMonitor application to LifeTimeAppPool   
            Set-ItemProperty 'IIS:\Sites\Default Web Site\PerformanceMonitor' applicationPool LifeTimeAppPool            
        }
    }

    Write-Host "LifeTime Application Pool Tunning Complete" "`n" -ForegroundColor Green

    #Write-Host "Tunning IIS"

    #----Tune IIS----
    #--------------------------------

    Write-Host "Tunning IIS" "`n"

    cd IIS:\

    #--------------------------------


    # Get Platform directory registry
    $OSPath = Get-ItemProperty $OSPathReg

    #Get partition where Platform is installed
    $OSDrive = $OSPath.'(default)'.Chars(0)

    # Get Windows directory
    $Windowspath = [Environment]::GetFolderPath("Windows")
    $Windowspath 

    if($OSDrive -eq $Windowspath.Chars(0)){

        Write-Host "The OutSystems Platform was installed in the same disk partition as Windows, it's advisable to install the OutSystems Platform in a separate partition for performance improvements" -ForegroundColor Yellow


    }else{
        
        $IIS_DotNET_Path = $OSDrive+":\IIS_Temp\IIS_DotNET_Compilation"


        if (!(Test-Path $IIS_DotNET_Path -pathType container)){

            New-Item $IIS_DotNET_Path -type directory

        }

        $IIS_Compression = $OSDrive+":\IIS_Temp\IIS_Compression"

        if (!(Test-Path $IIS_Compression -pathType container)){

            New-Item $IIS_Compression -type directory

        }


        #Set IIS Compression temporary folder

        Set-WebConfigurationProperty -filter /system.webServer -name 'sections["httpCompression"].OverrideModeDefault' -value Allow  -pspath iis:\
        Set-WebConfigurationProperty -filter /system.webServer -name 'sections["httpCompression"].allowDefinition' -value Everywhere  -pspath iis:\

        Set-WebConfigurationProperty /system.webServer/httpCompression -Name directory -value $IIS_Compression -pspath iis:\

        Write-Host "IIS Compression Complete" "`n" -ForegroundColor Green

        #Set .NET Compilation temporary files directory
        Set-WebConfigurationProperty  -filter 'system.web/compilation' -name 'tempDirectory' -value $IIS_DotNET_Path -pspath 'MACHINE/WEBROOT'

        Write-Host ".NET Compilation Complete" "`n" -ForegroundColor Green

        #Configure unlimited connections
        Set-WebConfigurationProperty -filter /system.applicationHost -name 'sections["webLimits"].OverrideModeDefault' -value Allow  -pspath iis:\
        Set-WebConfigurationProperty -filter /system.applicationHost -name 'sections["webLimits"].allowDefinition' -value Everywhere  -pspath iis:\

        Set-WebConfigurationProperty '/system.applicationHost/sites/site[@name="Default Web Site"]' -Name Limits -Value @{MaxConnections=4294967295} iis:\ #Default value, same as the checkbox was unchecked

        Write-Host "Unlimited Connections Complete" "`n" -ForegroundColor Green

    }


    #Setting up security directives to prevent Clickjacking. 
    #--------------------------------

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration") | Out-Null
    $iis = new-object Microsoft.Web.Administration.ServerManager

    $SectionGroup = $iis.GetWebConfiguration("Default Web Site")
    $httpProtocolSection = $SectionGroup.GetSection("system.webServer/httpProtocol")
    $customHeadersCollection = $httpProtocolSection.GetCollection("customHeaders")

    #Check if X-Frame-Options HTTP Custom Response Headers exists
    $FirstCustomHeader = Get-WebConfigurationProperty -PSPath "IIS:\sites\Default Web Site" `
    -Filter system.webServer/httpProtocol/customHeaders -Name .  `
    | WHERE {  $_.Collection | WHERE { $_.name -eq  "X-Frame-Options" }  } | measure

    if($FirstCustomHeader.Count -ne 0) {
        Write-Host "X-Frame-Options Custom Header exists" "`n" -ForegroundColor Green
    }else{
        $FirstHeader = $customHeadersCollection.CreateElement("add")
        $FirstHeader["name"] = "X-Frame-Options"
        $FirstHeader["value"] = "SAMEORIGIN"
        $customHeadersCollection.Add($FirstHeader)
        Write-Host "X-Frame-Options Custom Header added" "`n" -ForegroundColor Green
    }


    #Check if Content-Security-Policy HTTP Custom Response Headers exists
    $SecondCustomHeader = Get-WebConfigurationProperty -PSPath "IIS:\sites\Default Web Site" `
    -Filter system.webServer/httpProtocol/customHeaders -Name .  `
    | WHERE {  $_.Collection | WHERE { $_.name -eq  "Content-Security-Policy" }  } | measure

    if($SecondCustomHeader.Count -ne 0) {
        Write-Host "Content-Security-Policy Custom Header exists" "`n" -ForegroundColor Green
    }else{
        $SecondHeader = $customHeadersCollection.CreateElement("add")
        $SecondHeader["name"] = "Content-Security-Policy"
        $SecondHeader["value"] = "frame-ancestors 'self'"
        $customHeadersCollection.Add($SecondHeader)
        Write-Host "Content-Security-Policy Custom Header added" "`n" -ForegroundColor Green
    }

    $iis.CommitChanges() 

    Write-Host "Clickjacking Prevention Complete" "`n" -ForegroundColor Green



    #----Tune Windows----
    #--------------------------------

    Write-Host "Tunning Windows" "`n"

    #Process scheduling
    #------------------------------

    Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation"  -Value 0x18

    Write-Host "Process scheduling Complete" "`n" -ForegroundColor Green


    #Disabling SSLv3 to prevent vulnerability
    #--------------------------

    #Disabling SSL 3.0
    if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0")){
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "SSL 3.0"
        
        if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client")){
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -Name Client
        }

        if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server")){
           New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -Name Server
        }

        if((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client").GetValue("DisabledByDefault") -ne 1){
           New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name DisabledByDefault -PropertyType DWORD -Value 1
        }

        if((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server").GetValue("Enable") -ne 0){
           New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name Enable -PropertyType DWORD -Value 0
        }    
    }


    #Disabling SSL 2.0
    if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0")){
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "SSL 2.0"
        
        if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client")){
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0" -Name Client
        }

        if(!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server")){
           New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0" -Name Server
        }

        if((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client").GetValue("DisabledByDefault") -ne 1){
           New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -Name DisabledByDefault -PropertyType DWORD -Value 1
        }

        if((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server").GetValue("Enable") -ne 0){
           New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name Enable -PropertyType DWORD -Value 0
        }    
    }

    Write-Host "SSLv3 Vulnerability Prevention Complete" "`n" -ForegroundColor Green


    #Configure upload size limits
    #----------------------------


    [System.XML.XMLDocument]$XmlDocument = Get-Content -Path "$Windowspath\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config"


    if($XmlDocument.DocumentElement.'system.web'.httpRuntime -ne $null){

        $XmlDocument.DocumentElement.'system.web'.httpRuntime.maxRequestLength = "131072"

    }else{

        [System.XML.XMLElement]$NewNodeChild = $XmlDocument.CreateElement("httpRuntime")
        
        $NewNodeChild.SetAttribute("maxRequestLength", "131072")
        $XmlDocument.DocumentElement.'system.web'.AppendChild($NewNodeChild)
        
    }

    $XmlDocument.Save("$Windowspath\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config")


    #--------------------


    [System.XML.XMLDocument]$XmlDocument = Get-Content -Path  "$Windowspath\system32\inetsrv\config\applicationHost.config"

    if($XmlDocument.DocumentElement.'system.webServer'.security.requestFiltering.requestLimits -ne $null){
        
        $XmlDocument.DocumentElement.'system.webServer'.security.requestFiltering.requestLimits.maxAllowedContentLength = 134217728

    }else{

        [System.XML.XMLElement]$NewNodeChild = $XmlDocument.CreateElement("requestLimits")
        $NewNodeChild.SetAttribute("maxAllowedContentLength", "134217728")
        $XmlDocument.DocumentElement.'system.webServer'.security.requestFiltering.AppendChild($NewNodeChild)
        
    }

    $XmlDocument.Save("$Windowspath\system32\inetsrv\config\applicationHost.config")


}else{

    Write-Host "OutSystems Platform is not installed" "`n" -ForegroundColor Yellow
    
    Write-Host "OutSystems Platform Tunning aborted" "`n" -ForegroundColor Yellow

}

Read-Host -Prompt 'Press any key to exit the validator and close this window'