# set your own environments
$UserName = "username"
$YourPassword = "password"
$ProxyHostName = "ProxyHostName"
$ProxyPortNo = "8080"

Function Set-AuthProxy {

    # Set User Enviroment at this settion only
    $EnvProxy = "http://" + $UserName + ":" + $YourPassword + "@" + $ProxyHostName + ":" + $ProxyPortNo

    $env:http_proxy = $EnvProxy
    $env:https_proxy = $EnvProxy
    $env:ftp_proxy = $EnvProxy

    # Set PowerShell default proxy
    $ProxyAddress = "http://" + $ProxyHostName + ":" + $ProxyPortNo

    $SecurePassword = ConvertTo-SecureString $YourPassword -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential $UserName, $SecurePassword
    $WebProxy = New-Object System.Net.WebProxy $ProxyAddress
    $WebProxy.Credentials = $Credential
    [System.Net.WebRequest]::DefaultWebProxy = $WebProxy

}