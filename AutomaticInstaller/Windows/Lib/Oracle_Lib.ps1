
function Oracle_Configuration {
    
    param(
        $Xml_hsconf,
        [string]$NamingMethod,
        [string]$Host,
        [string]$Port,
        [string]$ServiceName,
        [string]$ToggleAdvancedSettings,
        [string]$RuntimeAppsConnString,
        [string]$OutSystemsServicesConnString,
        [string]$ErrorMessageLanguage,
        [string]$DefaultQueryTimeout,
        [string]$DatabaseUpdateQueryTimeout,
        [string]$TNSName,
        [string]$AdminUser,  
        [string]$AdminPwd,
        [string]$ADMIN_Tablespace,
        [string]$IndexTablespace,
        [string]$RuntimeUser,
        [string]$RuntimePwd,
        [string]$Runtime_Tablespace,
        [string]$LogUser,
        [string]$LogPwd,
        [string]$Log_Tablespace,
        [string]$SessionHost,
        [string]$SessionPort,
        [string]$Session_ServiceName,
        [string]$ToggleAdvancedSessionSettings,
        [string]$ExtraParameters,
        [string]$SessionErrorMessageLanguage,
        [string]$Session_TNSName,
        [string]$SessionUser,
        [string]$SessionPwd,
        [string]$Session_Tablespace,
        [string]$Controller
    )
        
    #-------------Database Tab--------------#
    
    # Set Naming Method
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.NamingType.InnerText = $NamingMethod

    if($NamingMethod -eq "Service Name"){

        # Set database host 
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Host.InnerText = $Host

        # Set database Port
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Port.InnerText = $Port

        # Set Service Name
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ServiceName.InnerText = $ServiceName


    }else{
    
         # Set TNS Name
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.TNSName.InnerText = $TNSName
    
    }


    <#
    # Set Advanced Settings
    if($ToggleAdvancedSettings -eq "Yes"){
    
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeAdvancedSettings.InnerText = $RuntimeAppsConnString
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ServicesAdvancedSettings.InnerText = $OutSystemsServicesConnString
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdvancedConfigurationMode.InnerText = $True
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.NLS_Language.InnerText = $ErrorMessageLanguage
        
        $Xml_hsconf.EnvironmentConfiguration.OtherConfigurations.DBTimeout = $DefaultQueryTimeout
        $Xml_hsconf.EnvironmentConfiguration.OtherConfigurations.DBUpdateTimeout = $DatabaseUpdateQueryTimeout

    }
    #>
    
        
    # Set Admin user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminUser.InnerText = $AdminUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($AdminPwd)
    $AdminPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $AdminPwd
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminTablespace.InnerText = $ADMIN_Tablespace
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.IndexTablespace.InnerText = $IndexTablespace
       
    # Set Runtime user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $RuntimeUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($RuntimePwd)
    $RuntimePwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $RuntimePwd
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminTablespace.InnerText = $Runtime_Tablespace

    # Set Log user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = $LogUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($LogPwd)
    $LogPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = $LogPwd
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminTablespace.InnerText = $Log_Tablespace


    #------------Session Tab------------#

    # Set Naming Method
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.IdType.InnerText = $NamingMethod

    if($NamingMethod -eq "Service Name"){

        # Set database host 
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Host.InnerText = $Host

        # Set database Port
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Port.InnerText = $Port

        # Set Service Name
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.ServiceName.InnerText = $ServiceName


    }else{
    
         # Set TNS Name
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.TNSName.InnerText = $TNSName
    
    }

    <#
    if($ToggleAdvancedSessionSettings -eq "Yes"){
    
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.AdvancedConfigurationMode.InnerText = $True
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionAdvancedSettings.InnerText = $ExtraParameters
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.NLS_Language.InnerText = $SessionErrorMessageLanguage        
        
    }
    #>


    # Set Session user credentials
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $SessionUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SessionPassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SessionPwd)
    $SessionPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $SessionPwd    
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SessionTablespace.InnerText = $Session_Tablespace

    
    #------------Controller Tab------------#

    # Set session database server 
    $Xml_hsconf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

    
    $Xml_hsconf.Save($OS.'(default)'+'\Server.hsconf')
}


function Oracle_Validation {
    
    param(
        $Xml_hsconf
    )


    # Choosing naming method

    $title = "Naming Method"
    $message = "Please choose the database naming method"

    $one = New-Object System.Management.Automation.Host.ChoiceDescription "&Service Name", `
        "Service Name"

    $two = New-Object System.Management.Automation.Host.ChoiceDescription "&TNS Name", `
        "TNS Name"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$NamingMethod = "Service Name" ; "You selected Service Name" } 
            1 {$NamingMethod = "TNS Name" ; "You selected TNS Name"}
        }


    #------------Database Tab-------------

    if($NamingMethod -eq "Service Name"){
    
        # Insert Host hostname or IP
        Do{
    
            [string]$Host = Read-Host "Host [localhost]"

            if(!$Host){
            
               $Host = "localhost"

            }

        }
        Until($Host)


        # Insert Database Port
        Do{
    
            [string]$Port = Read-Host "Port [1521]"
        
            if(!$Port){
        
                $Port = "1521"

            }
        }
        Until($Port)


        # Insert Service Name
        Do{
    
            [string]$ServiceName = Read-Host "Service Name"
        
            if(!$ServiceName){
        
                Write-Host "Required Field!"

            }
        }
        Until($ServiceName)

    }else{


        # Insert TNS Name
        Do{
    
            [string]$TNSName = Read-Host "TNS Name"

            if(!$TNSName){
            
                Write-Host "Required Field!"

            }
        }
        Until($TNSName)    
    }

   
    # Advanced Settings
    # --------------------------------------------
    
    $title = "Advanced Settings"
    $message = "Do you want to proceed with advanced settings?"

    $One = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Yes"

    $Two = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "No"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($One, $Two)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$ToggleAdvancedSettings = "Yes" ; "You selected Yes" } 
            1 {$ToggleAdvancedSettings = "No" ; "You selected No"}
        }
    
    if($ToggleAdvancedSettings -eq "Yes"){
    
        Write-Host "Advanced Connection Strings"
        Write-Host "`nEg: Max Pool Size = 100; Connection Timeout = 15;" -ForegroundColor Yellow
        [string]$RuntimeAppsConnString = Read-Host "Runtime Applications [Incr Pool Size=1;]"
        if(!$RuntimeAppsConnString){
        
            $RuntimeAppsConnString = "Incr Pool Size=1;"

        }
                
        
        [string]$OutSystemsServicesConnString = Read-Host "OutSystems Services [Incr Pool Size=1;]"
        if(!$OutSystemsServicesConnString){
        
            $OutSystemsServicesConnString = "Incr Pool Size=1;"

        }

        Write-Host "`nThis overrides the values of the NLS_LANGUAGE parameter." -ForegroundColor Yellow
        $ErrorMessageLanguage = Read-Host "Error Messages Language"
               
             
        [string]$DefaultQueryTimeout = Read-Host "Default Query Timeout [30]"

        if(!$DefaultQueryTimeout){
        
            $DefaultQueryTimeout = 30

        }

        Write-Host "1-Click Publish"
        [string]$DatabaseUpdateQueryTimeout = Read-Host "Database Update Query Timeout (secs.) [600]"

        if(!$DatabaseUpdateQueryTimeout){
        
            $DatabaseUpdateQueryTimeout = 600

        }        

    }
    

    # Insert Administrator user, password, TableSpce, Index TableSpace
    [string]$AdminUser
    $AdminUser = Read-Host "Administrator user [OSADMIN]"
    if(!$AdminUser){
    
        $AdminUser = "OSADMIN"
    
    }

    
    Do{
    
        [string]$AdminPwd = Read-Host "Administrator password" -asSecureString

        if(!$AdminPwd){
        
            Write-Host "Required Field!"

        }

    }Until($AdminPwd)
    
    
    Do{
    
        [string]$ADMIN_Tablespace
        $ADMIN_Tablespace = Read-Host "Tablespace [OSSYS]"

        if(!$ADMIN_Tablespace){
        
            $ADMIN_Tablespace = "OSSYS"

        }

    }Until($ADMIN_Tablespace)


    Do{
    
        [string]$IndexTablespace
        $IndexTablespace = Read-Host "Index Tablespace [OSIDX]"

        if(!$IndexTablespace){
        
            $IndexTablespace = "OSIDX"

        }

    }Until($IndexTablespace)




    # Insert Runtime user and password
    [string]$RuntimeUser
    $RuntimeUser = Read-Host "Runtime user [OSRUNTIME]"
    if(!$RuntimeUser){
    
        $RuntimeUser = "OSRUNTIME"
    
    }

    
    Do{
    
        [string]$RuntimePwd = Read-Host "Runtime user password" -asSecureString

        if(!$RuntimePwd){
        
            Write-Host "Required Field!"

        }

    }Until($RuntimePwd)
    

    Do{
    
        [string]$Runtime_Tablespace
        $Runtime_Tablespace = Read-Host "Tablespace [OSUSR]"

        if(!$Runtime_Tablespace){
        
            $Runtime_Tablespace = "OSUSR"

        }

    }Until($Runtime_Tablespace)




    # Insert Log user and password
    [string]$LogUser
    $LogUser = Read-Host "Log user [OSLOG]"
    if(!$LogUser){
    
        $LogUser = "OSLOG"
    
    }

    
    Do{
    
        [string]$LogPwd = Read-Host "Log user password" -asSecureString

        if(!$LogPwd){
        
            Write-Host "Required Field!"

        }

    }Until($LogPwd)
    

    Do{
    
        [string]$Log_Tablespace
        $Log_Tablespace = Read-Host "Tablespace [OSLOG]"

        if(!$Log_Tablespace){
        
            $Log_Tablespace = "OSLOG"

        }

    }Until($Log_Tablespace)

    #-------------Session Tab-----------------

    # Insert Session user, password, TableSpce, Index TableSpace
    if($NamingMethod -eq "Service Name"){
    
        # Insert Host hostname or IP
        Do{
    
            [string]$SessionHost = Read-Host "Session Host [localhost]"

            if(!$SessionHost){
            
               $SessionHost = "localhost"

            }

        }
        Until($SessionHost)


        # Insert Database Port
        Do{
    
            [string]$SessionPort = Read-Host "Port [1521]"
        
            if(!$SessionPort){
        
                $SessionPort = "1521"

            }
        }
        Until($SessionPort)


        # Insert Service Name
        Do{
    
            [string]$Session_ServiceName = Read-Host "Service Name"
        
            if(!$Session_ServiceName){
        
                Write-Host "Required Field!"

            }
        }
        Until($Session_ServiceName)

    }else{


        # Insert TNS Name
        Do{
    
            [string]$Session_TNSName = Read-Host "TNS Name"

            if(!$Session_TNSName){
            
                Write-Host "Required Field!"

            }
        }
        Until($Session_TNSName)    
    }


    
    # Session Advanced Settings
    # --------------------------------------------
    
    $title = "Advanced Session Database Settings"
    $message = "Do you want to proceed with session advanced settings?"

    $One = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Yes"

    $Two = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "No"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($One, $Two)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$ToggleAdvancedSessionSettings = "Yes" ; "You selected Yes" } 
            1 {$ToggleAdvancedSessionSettings = "No" ; "You selected No"}
        }
    
    if($ToggleAdvancedSessionSettings -eq "Yes"){
    
        Write-Host "Advanced Connection Strings"
        Write-Host "`nMax Pool Size = 100; Connection Timeout = 15;" -ForegroundColor Yellow
        [string]$ExtraParameters = Read-Host "Extra Parameters [Incr Pool Size=1;]"

        if(!$ExtraParameters){
        
            $ExtraParameters = "Incr Pool Size=1;"

        }
        
        Write-Host "`nThis overrides the values of the NLS_LANGUAGE parameter." -ForegroundColor Yellow
        $SessionErrorMessageLanguage = Read-Host "Error Messages Language"
    }




     # Insert Session user and password
    [string]$SessionUser
    $SessionUser = Read-Host "Session user [OSSTATE]"
    if(!$SessionUser){
    
        $SessionUser = "OSSTATE"
    
    }


    
    Do{
    
        [string]$SessionPwd = Read-Host "Session user password" -asSecureString

        if(!$SessionPwd){
        
            Write-Host "Required Field!"

        }

    }Until($SessionPwd)
    

    Do{
    
        [string]$Session_Tablespace
        $Session_Tablespace = Read-Host "Tablespace [OSSTATE]"

        if(!$Session_Tablespace){
        
            $Session_Tablespace = "OSSTATE"

        }

    }Until($Session_Tablespace)


    #-------------Controller Tab-----------------

    # Insert Deployment Controller Server
    [string]$Controller
    $Controller = Read-Host "Deployment Controller Server [localhost]: "
    if(!$Controller){
    
        $Controller = "localhost"

    }

    Oracle_Configuration -Xml_hsconf $Xml_hsconf -NamingMethod $NamingMethod -Host $Host -Port $Port -ServiceName $ServiceName -TNSName $TNSName -AdminUser $AdminUser -AdminPwd $AdminPwd -ADMIN_Tablespace $ADMIN_Tablespace -IndexTablespace $IndexTablespace -RuntimeUser $RuntimeUser -RuntimePwd $RuntimePwd -Runtime_Tablespace $Runtime_Tablespace -LogUser $LogUser -LogPwd $LogPwd -Log_Tablespace $Log_Tablespace -SessionHost $SessionHost -SessionPort $SessionPort -Session_ServiceName $Session_ServiceName -Session_TNSName $Session_TNSName -SessionUser $SessionUser -SessionPwd $SessionPwd -Session_Tablespace $Session_Tablespace -Controller $Controller
    
}