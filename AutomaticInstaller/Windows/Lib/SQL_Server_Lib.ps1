
function SQL_Server_Configuration {
    
    param(
        $Xml_hsconf,
        [string]$Server,
        [string]$Database,
        [string]$DatabaseAuthentication,
        [string]$ToggleAdvancedSettings,
        [string]$RuntimeAppsConnString,
        [string]$OutSystemsServicesConnString,
        [string]$DefaultQueryTimeout,
        [string]$DatabaseUpdateQueryTimeout,
        [string]$AdminUser,
        [string]$AdminPwd,
        [string]$RuntimeUser,  
        [string]$RuntimePwd,
        [string]$LogUser,
        [string]$LogPwd,
        [string]$SessionServer,
        [string]$SessionDatabase,
        [string]$ToggleAdvancedSessionSettings,
        [string]$ExtraParameters,
        [string]$SessionUser,
        [string]$SessionPwd,
        [string]$Controller
    )
        
    #-------------Database Tab--------------#
    
    # Set database server 
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Server.InnerText = $Server

    # Set database
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Catalog.InnerText = $Database
        
    # Set authentication mode
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = $DatabaseAuthentication

    <#
    # Set Advanced Settings
    if($ToggleAdvancedSettings -eq "Yes"){
    
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeAdvancedSettings.InnerText = $RuntimeAppsConnString
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ServicesAdvancedSettings.InnerText = $OutSystemsServicesConnString
        $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdvancedConfigurationMode.InnerText = $True

        
        $Xml_hsconf.EnvironmentConfiguration.OtherConfigurations.DBTimeout = $DefaultQueryTimeout
        $Xml_hsconf.EnvironmentConfiguration.OtherConfigurations.DBUpdateTimeout = $DatabaseUpdateQueryTimeout

    }
    #>

    # Set Admin user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminUser.InnerText = $AdminUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.SetAttribute("encrypted", "false")
    
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $AdminPwd
       
    # Set Runtime user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $RuntimeUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.SetAttribute("encrypted", "false")
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $RuntimePwd

    # Set Log user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = $LogUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.SetAttribute("encrypted", "false")
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = $LogPwd


    #------------Session Tab------------#

    # Set session database server 
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Server.InnerText = $SessionServer

    # Set session database
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Catalog.InnerText = $SessionDatabase

    # Set Session Advanced parameters

    <#
    if($ToggleAdvancedSessionSettings -eq "Yes"){
    
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.AdvancedConfigurationMode.InnerText = $True
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionAdvancedSettings.InnerText = $ExtraParameters
        
    }
    #>

    # Set Session user credentials
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $SessionUser
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.SetAttribute("encrypted", "false")
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $SessionPwd

    
    #------------Controller Tab------------#

    # Set session database server 
    $Xml_hsconf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

    
    $Xml_hsconf.Save($OS.'(default)'+'\Server.hsconf')
}


function SQL_Server_Validation {
    
    param(
        $Xml_hsconf
    )
    
    #------------Database Tab-------------

    # Insert Server hostname or IP
    Do{
    
        [string]$Server = Read-Host "Server"

        if(!$Server){
            
            Write-Host "Required Field!"

        }
    }
    Until($Server)


    # Insert Database connection string
    Do{
    
        [string]$Database = Read-Host "Database"
        
        if(!$Database){
        
            Write-Host "Required Field!"

        }
    }
    Until($Database)


    # Choose Database Authentication method
    $title = "Database Authentication method"
    $message = "Please choose the database authentication method"

    $One = New-Object System.Management.Automation.Host.ChoiceDescription "&Database Authentication", `
        "Database Authentication"

    $Two = New-Object System.Management.Automation.Host.ChoiceDescription "&Windows Authentication", `
        "Windows Authentication"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($One, $Two)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$DatabaseAuthentication = "Database Authentication" ; "You selected Database Authentication" } 
            1 {$DatabaseAuthentication = "Windows Authentication" ; "You selected Windows Authentication"}
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
        [string]$RuntimeAppsConnString = Read-Host "Runtime Applications"
        Write-Host "`nMax Pool Size = 100; Connection Timeout = 15;" -ForegroundColor Yellow
        [string]$OutSystemsServicesConnString = Read-Host "OutSystems Services"
             
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

    #----------------------------

    # Insert Administrator user and password
    [string]$AdminUser
    $AdminUser = Read-Host "Administrator user [OSADMIN]"
    if(!$AdminUser){
    
        $AdminUser = "OSADMIN"
    
    }
        

    Do{
    
        [System.Security.SecureString]$AdminPwd = Read-Host "Administrator password" -AsSecureString
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($AdminPwd)
        [string]$AdminPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

        if(!$AdminPwd){
        
            Write-Host "Required Field!"

        }

    }Until($AdminPwd)
    
    # Insert Runtime user and password
    [string]$RuntimeUser
    $RuntimeUser = Read-Host "Runtime user [OSRUNTIME]"
    if(!$RuntimeUser){
    
        $RuntimeUser = "OSRUNTIME"
    
    }

    
    Do{
    
        [System.Security.SecureString]$RuntimePwd = Read-Host "Runtime user password" -AsSecureString
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($RuntimePwd)
        [string]$RuntimePwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

        if(!$RuntimePwd){
        
            Write-Host "Required Field!"

        }

    }Until($RuntimePwd)
    

    # Insert Log user and password
    [string]$LogUser
    $LogUser = Read-Host "Log user [OSLOG]"
    if(!$LogUser){
    
        $LogUser = "OSLOG"
    
    }

    
    Do{
    
        [System.Security.SecureString]$LogPwd = Read-Host "Log user password" -AsSecureString
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($LogPwd)
        [string]$LogPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

        if(!$LogPwd){
        
            Write-Host "Required Field!"

        }

    }Until($LogPwd)
    

    #-------------Session Tab-----------------

    # Insert Session Server hostname or IP
    Do{
    
        [string]$SessionServer = Read-Host "Session Server"

        if(!$SessionServer){
            
            Write-Host "Required Field!"

        }
    }
    Until($SessionServer)


    # Insert Session Database connection string
    Do{
    
        [string]$SessionDatabase = Read-Host "Session Database" 

        if(!$SessionDatabase){
        
            Write-Host "Required Field!"

        }
    }
    Until($SessionDatabase)


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
        [string]$ExtraParameters = Read-Host "Extra Parameters"
        Write-Host "`nMax Pool Size = 100; Connection Timeout = 15;" -ForegroundColor Yellow
    }

     # Insert Session user and password
    [string]$SessionUser
    $SessionUser = Read-Host "Session user [OSSTATE]"
    if(!$SessionUser){
    
        $SessionUser = "OSSTATE"
    
    }


    
    Do{
    
        [System.Security.SecureString]$SessionPwd = Read-Host "Session user password" -AsSecureString
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SessionPwd)
        [string]$SessionPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

        if(!$SessionPwd){
        
            Write-Host "Required Field!"

        }

    }Until($SessionPwd)
    

    #-------------Controller Tab-----------------

    # Insert Deployment Controller Server
    [string]$Controller
    $Controller = Read-Host "Deployment Controller Server [localhost]: "
    if(!$Controller){
    
        $Controller = "localhost"

    }

    SQL_Server_Configuration -Xml_hsconf $Xml_hsconf -Server $Server -Database $Database -DatabaseAuthentication $DatabaseAuthentication -ToggleAdvancedSettings $ToggleAdvancedSettings -RuntimeAppsConnString $RuntimeAppsConnString -OutSystemsServicesConnString $OutSystemsServicesConnString -DefaultQueryTimeout $DefaultQueryTimeout -DatabaseUpdateQueryTimeout $DatabaseUpdateQueryTimeout -AdminUser $AdminUser -AdminPwd $AdminPwd -RuntimeUser $RuntimeUser -RuntimePwd $RuntimePwd -LogUser $LogUser -LogPwd $LogPwd -SessionServer $SessionServer -SessionDatabase $SessionDatabase -ToggleAdvancedSessionSettings $ToggleAdvancedSessionSettings -ExtraParameters $ExtraParameters -SessionUser $SessionUser -SessionPwd $SessionPwd -Controller $Controller
    
    
}