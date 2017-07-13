
function MySQL_Configuration {
    
    param(
        $Xml_hsconf,
        [string]$Server,
        [string]$Schema,
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
        [string]$SessionSchema,
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
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Schema.InnerText = $Schema
   
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
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($AdminPwd)
    $AdminPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $AdminPwd
       
    # Set Runtime user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $RuntimeUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($RuntimePwd)
    $RuntimePwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $RuntimePwd

    # Set Log user credentials
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = $LogUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($LogPwd)
    $LogPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = $LogPwd


    #------------Session Tab------------#

    # Set session database server 
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Server.InnerText = $SessionServer

    # Set session database
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.Schema.InnerText = $SessionSchema

    
    # Set Session Advanced parameters

    <#
    if($ToggleAdvancedSessionSettings -eq "Yes"){
    
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.AdvancedConfigurationMode.InnerText = $True
        $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionAdvancedSettings.InnerText = $ExtraParameters
        
    }
    #>


    # Set Session user credentials
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $SessionUser
    $Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SessionPassword.SetAttribute("encrypted", "false")
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SessionPwd)
    $SessionPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
    $Xml_hsconf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $SessionPwd

    
    #------------Controller Tab------------#

    # Set session database server 
    $Xml_hsconf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

    
    $Xml_hsconf.Save($OS.'(default)'+'\Server.hsconf')
}


function MySQL_Validation {
    
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
    
        [string]$Schema = Read-Host "Schema"
        
        if(!$Schema){
        
            Write-Host "Required Field!"

        }
    }
    Until($Schema)

  
    
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

    # Insert Administrator user and password
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
    

    #-------------Session Tab-----------------

    # Insert Session Server hostname or IP
    Do{
    
        [string]$SessionServer = Read-Host "Session Server"

        if(!$SessionServer){
            
            Write-Host "Required Field!"

        }
    }
    Until($SessionServer)


    # Insert Session Schema connection string
    Do{
    
        [string]$SessionSchema = Read-Host "Session Schema"

        if(!$SessionSchema){
        
            Write-Host "Required Field!"

        }
    }
    Until($SessionSchema)


    
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
     
        [string]$SessionPwd = Read-Host "Session user password" -asSecureString

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

    MySQL_Configuration -Xml_hsconf $Xml_hsconf -Server $Server -Schema $Schema -AdminUser $AdminUser -AdminPwd $AdminPwd -RuntimeUser $RuntimeUser -RuntimePwd $RuntimePwd -LogUser $LogUser -LogPwd $LogPwd -SessionServer $SessionServer -SessionSchema $SessionSchema -SessionUser $SessionUser -SessionPwd $SessionPwd -Controller $Controller
    
}