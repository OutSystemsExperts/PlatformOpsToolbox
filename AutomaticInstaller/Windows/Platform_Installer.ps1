
#Current Installer Script Path
[string]$InstallerScriptPath =  ($pwd).path

# Check if the script was runned from Toolbox or directly
if($InstallerScriptPath -notlike "*AutomaticInstaller\Windows"){
    $InstallerScriptPath += "\AutomaticInstaller\Windows"
}


#Install Devlopment Tools
#---------------------------------

$FileDevTools = Get-ChildItem $InstallerScriptPath\bin\*.exe  | Where-Object {("{0}" -f [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileDescription) -match "Development Environment Installer"} -ErrorAction Stop

        if($FileDevTools){
        		
                
                try{
                    write-host "Development Tools "$FileDevTools.VersionInfo.FileVersion" executable founded, starting installation " "`n" -ForegroundColor Green

                    Start-Process $FileDevTools -ErrorAction SilentlyContinue -Wait
                    
                    #Wait-Process $FileDevTools -ErrorAction SilentlyContinue

                    <#
                    $ps = new-object System.Diagnostics.Process
                    $ps.StartInfo.Filename = $FileDevTools.Name
                    $ps.StartInfo.RedirectStandardOutput = $True
                    $ps.StartInfo.RedirectStandardError = $True
                    $ps.StartInfo.UseShellExecute = $false
                    $ps.EnableRaisingEvents = $True

                    $ps.Start()
                    
                    $ps.WaitForExit()
                    #>
                }
                catch{
                    Write-Warning "An error occurred"
                    $_.Exception.Message
                    exit
                }
                
         }else{
            write-host "Development Tools executable is missing" "`n" -ForegroundColor Red 
            write-host "OutSystems Platform Development Tools installation aborted" "`n" -ForegroundColor Red
            exit
            #Read-Host "pause 1"
         }



#Install Platform Server
#---------------------------------

$FilePlatformServer = Get-ChildItem $InstallerScriptPath\bin\*.exe  | Where-Object {("{0}" -f [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileDescription) -match "Platform Server Installer"} -ErrorAction Stop

        if($FilePlatformServer){
        		
                
                try{
                    write-host "Platform Server "$FilePlatformServer.VersionInfo.FileVersion" executable founded, starting installation " "`n" -ForegroundColor Green 

                    Start-Process $FilePlatformServer -ErrorAction SilentlyContinue -Wait
                    
                    #Wait-Process $FilePlatformServer -ErrorAction SilentlyContinue

                    <#
                    $ps = new-object System.Diagnostics.Process
                    $ps.StartInfo.Filename = $FilePlatformServer.Name
                    $ps.StartInfo.RedirectStandardOutput = $True
                    $ps.StartInfo.RedirectStandardError = $True
                    $ps.StartInfo.UseShellExecute = $false
                    $ps.EnableRaisingEvents = $True

                    $ps.Start()
                    
                    $ps.WaitForExit()
                    #>
                }
                catch{
                    Write-Warning "An error occurred"
                    $_.Exception.Message
                    exit
                }
                
         }else{
            write-host "Platform Server executable is missing" "`n" -ForegroundColor Red 
            write-host "OutSystems Platform Server installation aborted" "`n" -ForegroundColor Red
            exit
            #Read-Host "pause 2"
         } 





try{
    $OS = Get-ItemProperty HKLM:\SOFTWARE\OutSystems\Installer\Server -ErrorAction SilentlyContinue
}
catch{
    Write-Warning "Outsystems Platform Server is not installed on this server."
    #exit
            #Read-Host "pause 3"
}

$Directory = $OS.'(default)'
Set-Location -Path $Directory

# Set Configuration Tool
$ConfTool = $Directory + '\ConfigurationTool.exe'


#-------------------------------------------------------------

# OutSystems Platform First Installation

$title = "Database management system"
$message = "Please choose the database management system"

$one = New-Object System.Management.Automation.Host.ChoiceDescription "&SQL Server", `
    "SQL Server"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&Oracle", `
    "Oracle"

$three = New-Object System.Management.Automation.Host.ChoiceDescription "&MySQL", `
    "MySQL"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        '0' {$Database = "SqlServer" ; "You selected SQL Server" } 
        '1' {$Database = "Oracle" ; "You selected Oracle"}
        '2' {$Database = "MySQL" ; "You selected MySQL"}
    }




# Check if Server.hsconf already exists
if(Test-Path Server.hsconf){
   
    
    [System.XML.XMLDocument]$Xml_hsconf= Get-Content -Path Server.hsconf
               
    # Check what's the database management system

    if($Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ProviderKey -eq "SqlServer"){
    
        $ScriptPath = $InstallerScriptPath + "\Libs\SQL_Server_Lib.ps1"

        . $ScriptPath
       
       Write-Host $ScriptPath -ForegroundColor Yellow

        SQL_Server_Validation -Xml_hsconf $Xml_hsconf
        
    }

    if($Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ProviderKey -eq "Oracle"){
    
        $ScriptPath = $InstallerScriptPath + "\Libs\Oracle_Lib.ps1"

        . $ScriptPath

        Oracle_Validation -Xml_hsconf $Xml_hsconf

    }

    if($Xml_hsconf.EnvironmentConfiguration.PlatformDatabaseConfiguration.ProviderKey -eq "MySQL"){
    
        $ScriptPath = $InstallerScriptPath + "\Libs\MySQL_Lib.ps1"

        . $ScriptPath

        MySQL_Validation -Xml_hsconf $Xml_hsconf

    }


}else{

    # Generate server.hsconf templates
    & $ConfTool '/GenerateTemplates' | Out-Null
        
    $Directory = $OS.'(default)' + '\docs'
    Set-Location -Path $Directory 

    if($Database -eq "SqlServer"){
        
        Try{
            [System.XML.XMLDocument]$Xml_hsconf= Get-Content -Path SqlServer_template.hsconf -ErrorAction Stop
            $ScriptPath = $InstallerScriptPath + "\Libs\SQL_Server_Lib.ps1"

            . $ScriptPath
       
           #Write-Host $ScriptPath -ForegroundColor Yellow

            SQL_Server_Validation -Xml_hsconf $Xml_hsconf

        }
        Catch{
            Write-Host $_.Exception.Message
            Read-Host -Prompt 'Press any key to exit'
            exit
        }     
          
    
    }
    
    if($Database -eq "Oracle"){
    
        Try{
            [System.XML.XMLDocument]$Xml_hsconf= Get-Content -Path Oracle_template.hsconf -ErrorAction Stop
            $ScriptPath = $InstallerScriptPath + "\Libs\Oracle_Lib.ps1"

            . $ScriptPath

            Oracle_Validation -Xml_hsconf $Xml_hsconf
        }
        Catch{
            Write-Host $_.Exception.Message
            Read-Host -Prompt 'Press any key to exit'
            exit
        } 

    }

    if($Database -eq "MySQL"){
      
       Try{
            [System.XML.XMLDocument]$Xml_hsconf= Get-Content -Path MySQL_template.hsconf -ErrorAction Stop
            $ScriptPath = $InstallerScriptPath + "\Libs\MySQL_Lib.ps1"

            . $ScriptPath

            MySQL_Validation -Xml_hsconf $Xml_hsconf
        }
        Catch{
            Write-Host $_.Exception.Message
            Read-Host -Prompt 'Press any key to exit'
            exit
        } 

    }
}

$ps = new-object System.Diagnostics.Process
$ps.StartInfo.Filename = $ConfTool
$ps.StartInfo.RedirectStandardOutput = $True
$ps.StartInfo.RedirectStandardError = $True
$ps.StartInfo.UseShellExecute = $false
$ps.EnableRaisingEvents = $True


# Choose to install Service Center or not
    $title = "Service Center Installation"
    $message = "Do you want to install Service Center?"

    $OptionOne = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Yes"

    $OptionTwo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "No"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($OptionOne, $OptionTwo)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            '0' {$Choice = "Yes" ; "You selected Yes" } 
            '1' {$Choice = "No" ; "You selected No"}
        }
    
    
    Do{
        [string]$DBAdmin = Read-Host "Database Administrator"
        if(!$DBAdmin){
            
                Write-Host "Required Field!"

            }
    }
    Until($DBAdmin)
    
    Do{
        [System.Security.SecureString]$DBAdminPwd = Read-Host "Database Administrator password" -AsSecureString
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($DBAdminPwd)
        [string]$DBAdminPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

        if(!$DBAdminPwd){
            
                Write-Host "Required Field!"

            }
    }
    Until($DBAdminPwd)
    
   
    Write-Host "`nPlatform Runtime Database schema will be created."  -ForegroundColor Yellow
    Write-Host "Platform Session Database schema will be created."  -ForegroundColor Yellow


    if($Choice -eq "Yes"){
        
        $ps.StartInfo.Arguments = "/SetupInstall $DBAdmin $DBAdminPwd /RebuildSession $DBAdmin $DBAdminPwd /SCInstall"
        
        try{
            $ps.Start() | Out-Null -ErrorAction Stop
            Write-Host "Service Center will be installed." -ForegroundColor Yellow       
            Write-Host "`nThis process may take a while.`n" -ForegroundColor Yellow
            $ps.WaitForExit() | Out-Null -ErrorAction Stop            
        }
        catch{
            Write-Warning "An error occured!"
            if($ps.StandardError.EndOfStream -eq $false){
                Write-Host "Error: `n" -ForegroundColor DarkRed
                Write-Host $ps.StandardError.ReadToEnd() -ForegroundColor DarkRed
            }
            Write-Host $_.Exception.Message
            Read-Host -Prompt 'Press any key to exit'    
        }
        Finally{
           if($ps.StandardOutput.EndOfStream -eq $false){
               Write-Host $ps.StandardOutput.ReadToEnd() -ForegroundColor DarkYellow
           }
           $ps.ExitCode | Out-Null -ErrorAction Stop
        }    

    }else{
    
        $ps.StartInfo.Arguments = "/SetupInstall $DBAdmin $DBAdminPwd /RebuildSession $DBAdmin $DBAdminPwd"
        
        try{
            $ps.Start() | Out-Null -ErrorAction Stop
            Write-Host "`nThis process may take a while.`n" -ForegroundColor Yellow
            $ps.WaitForExit() | Out-Null -ErrorAction Stop            
        }
        catch{
            Write-Warning "An error occured!"
            if($ps.StandardError.EndOfStream -eq $false){
                Write-Host "Error: `n" -ForegroundColor DarkRed
                Write-Host $ps.StandardError.ReadToEnd() -ForegroundColor DarkRed
            }
            Write-Host $_.Exception.Message
            Read-Host -Prompt 'Press any key to exit'      
        }
        Finally{
           if($ps.StandardOutput.EndOfStream -eq $false){
                Write-Host $ps.StandardOutput.ReadToEnd() -ForegroundColor DarkYellow
           }
           $ps.ExitCode | Out-Null -ErrorAction Stop
        }
    }
    Read-Host -Prompt 'Press any key to continue'

    return