for %%k in (%4*.xif) DO %INTEGRATIONSTUDIO% -TestPublish -Xif "%%k" -Xml "%%k.xml" -HostName "%1" -UserName "%2" -Password "%3" 
