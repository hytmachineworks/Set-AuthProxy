# Set-AuthProxy
Proxy Authentication set credential info on PowerShell

## usage


### 1. start powershell as administrator and do below command

>Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


### 2. make a PowerShell_profile.ps1 and add Set-AuthProxy function

open or make PowerShell_profile.ps1 by below command
>notepad $profile

and write content below

>import-module Set-PSAuthProxy
>Set-AuthProxy

and save and close PowerShell_profile.ps1


### 3. install Set-AuthProxy.psm1

please check your module dir by below command

>$env:PSModulePath

and make Set-PSAuthProxy dir and save Set-PSAuthProxy.psm1


### 4. edit your personal info to Set-PSAuthProxy.psm1

>$UserName = "username"
>$YourPassword = "password"
>$ProxyHostName = "ProxyHostName"
>$ProxyPortNo = "8080"


### 5. restart powershell and activate Set-PSAuthProxy automatically
