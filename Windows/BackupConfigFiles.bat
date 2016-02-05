@echo OFF
setlocal ENABLEEXTENSIONS

@echo /---------------------------------------------------------------\
@echo  Backup of .NET, IIS and OutSystems Platform configuration files
@echo  ATTENTION: Make sure this script is run as Administrator!
@echo \---------------------------------------------------------------/
CHOICE /C YN /M "Press Y to continue, N to cancel"
IF ERRORLEVEL 2 GOTO End
IF %ERRORLEVEL% EQU 0 GOTO End

@echo Creating backup folders...
md ".\BackupConfigFiles\DOTNET2"
md ".\BackupConfigFiles\DOTNET4"
md ".\BackupConfigFiles\OS"
md ".\BackupConfigFiles\IIS"

@echo Copying .NET v2 config files...
copy %windir%\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config .\BackupConfigFiles\DOTNET2\machine.x32.v2.config
copy %windir%\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config .\BackupConfigFiles\DOTNET2\web.x32.v2.config
copy %windir%\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config .\BackupConfigFiles\DOTNET2\machine.x64.v2.config
copy %windir%\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config .\BackupConfigFiles\DOTNET2\web.x64.v2.config

@echo Copying .NET v4 config files...
copy %windir%\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config .\BackupConfigFiles\DOTNET4\machine.x32.v4.config
copy %windir%\Microsoft.NET\Framework\v4.0.30319\CONFIG\web.config .\BackupConfigFiles\DOTNET4\web.x32.v4.config
copy %windir%\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config .\BackupConfigFiles\DOTNET4\machine.x64.v4.config
copy %windir%\Microsoft.NET\Framework64\v4.0.30319\CONFIG\web.config .\BackupConfigFiles\DOTNET4\web.x64.v4.config

@echo Copying IIS config files...
copy %windir%\System32\inetsrv\config\applicationHost.config .\BackupConfigFiles\IIS
copy %windir%\..\inetpub\wwwroot\web.config .\BackupConfigFiles\IIS\DefaultWebSite.web.config

@echo Copying OutSystems Platform config files...
set KEY_NAME="HKLM\Software\OutSystems\Installer\Server"
FOR /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /ve 2^>nul`) DO (
    set ValueValue=%%C
)
if defined ValueValue (
	copy "%ValueValue%\*.config" .\BackupConfigFiles\OS
	copy "%ValueValue%\*.hsconf" .\BackupConfigFiles\OS
) else (
    @echo Unable to find OutSystems Platform installation folder.
)

:End
