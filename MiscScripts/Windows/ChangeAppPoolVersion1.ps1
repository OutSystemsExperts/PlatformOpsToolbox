try{
Import-Module WebAdministration
 
$webapps = Get-WebApplication
$list = @()
foreach ($webapp in get-childitem IIS:\AppPools\)
{
$name = "IIS:\AppPools\" + $webapp.name
$item = @{}
 
$item.WebAppName = $webapp.name
$item.Version = (Get-ItemProperty $name managedRuntimeVersion).Value
Set-ItemProperty $name managedRuntimeVersion v4.0
$item.NewVersion = (Get-ItemProperty $name managedRuntimeVersion).Value

 
$obj = New-Object PSObject -Property $item
$list += $obj
}
 
$list | Format-Table -a -Property "WebAppName", "Version", "NewVersion"
 
}catch
{
$ExceptionMessage = "Error in Line: " + $_.Exception.Line + ". " + $_.Exception.GetType().FullName + ": " + $_.Exception.Message + " Stacktrace: " + $_.Exception.StackTrace
$ExceptionMessage
}
