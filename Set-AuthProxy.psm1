# set your own environments
$ProxyHostName = "ProxyHostName"
$ProxyPortNo = "8080"

# set direction to save_password and aes key
# this setting is example. please set diffrent dirs!
$password_file_path = $env:USERPROFILE + "\ps.credential"
$aes_key_file_path = $env:USERPROFILE + "\ps.aes"

# whitch you get username by environ or not
# if UserName value is blank, use environ username
$UserName = "UserName"

# Program core ===========================================

if (!($UserName)) {
    $UserName = $env:USERNAME
}

Function Set-AuthProxy {

    Param(
        # parameter dedide proxy set or clear mode
        [Parameter(mandatory=$true)]
        [ValidateSet("Set", "Clear")]
        [string]
        $Set_or_Clear,

        # parameter dedide proxy set or clear mode
        [Parameter(mandatory=$false)]
        [ValidateSet("Keep", "Change")]
        [string]
        $Change_Pass = "Keep"
    )

    # password change mode
    if ($Change_Pass -eq "Change"){
        $Change_Pass_flag = $true
    }
    else{
        $Change_Pass_flag = $false
    }

    # check above pass and key files exists
    $password_file_flag = Test-Path $password_file_path -PathType Leaf
    $aes_key_file_flag = Test-Path $aes_key_file_path -PathType Leaf

    # check above pass and key file dirs exists
    $password_dir_path = Split-Path $password_file_path -Parent
    $aes_key_dir_path = Split-Path $aes_key_file_path -Parent

    $password_dir_flag = Test-Path $password_dir_path -PathType Container
    $aes_key_dir_flag = Test-Path $aes_key_dir_path -PathType Container

    if (($password_dir_flag -eq $false) -or ($aes_key_dir_flag -eq $false)){
        Write-Host "Invalid dir is specified. Please check pass file dir or aes key dir"
        Write-Host "Set Auth Proxy User Environments failure..."
        Write-Host ""

        $Set_or_Clear = "Set"
        $Change_Pass_flag = $false
        $Valid_Dir = $false
    }
    elseif (($password_file_flag -eq $false) -or ($aes_key_file_flag -eq $false)) {
        Write-Host "File does not exist!"
        Write-Host "Start to create credential files!"
        Write-Host ""

        $Change_Pass_flag = $true
        $Valid_Dir = $true
    }
    else {
        $Valid_Dir = $true
    }

    # password reset mode
    if ($Change_Pass_flag -eq $true) {
        $Credential = $Host.UI.PromptForCredential("Please update credential infomations", "Please enter your password.", $UserName,"")

        if ($null -eq $Credential){
            Write-Host "Your input password is invalid."
            Write-Host "Set Auth Proxy User Environments failure..."
            Write-Host "Please retry > AuthProxy Set Change"
            Write-Host ""

            $Set_or_Clear = "Set"
            $valid_input = $false
        }
        else {
            $Key = New-Object byte[] 32
            [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
            $Key | Out-File $aes_key_file_path

            $Credential.password | ConvertFrom-SecureString -Key $Key | Set-Content $password_file_path

            $Set_or_Clear = "Set"
            $valid_input = $true
        }

    }
    else {
        $valid_input = $true

    }

    # Set User Enviroment at this settion only
    if (($Set_or_Clear -eq "Set") -and ($valid_input -eq $true) -and ($Valid_Dir -eq $true)){

        $password = Get-Content $password_file_path | ConvertTo-SecureString -Key (Get-Content $aes_key_file_path)
        $Credential = New-Object System.Management.Automation.PSCredential $UserName, $password

        $EnvProxy = "http://" + $UserName + ":" + $Credential.GetNetworkCredential().Password + "@" + $ProxyHostName + ":" + $ProxyPortNo

        $env:http_proxy = $EnvProxy
        $env:https_proxy = $EnvProxy
        $env:ftp_proxy = $EnvProxy

        # Set PowerShell default proxy
        $ProxyAddress = "http://" + $ProxyHostName + ":" + $ProxyPortNo

        $WebProxy = New-Object System.Net.WebProxy $ProxyAddress
        $WebProxy.Credentials = $Credential
        [System.Net.WebRequest]::DefaultWebProxy = $WebProxy

        Write-Host "Set Auth Proxy User Environment"
        Write-Host ""

    }
    else {
        # Clear Auth proxy setting at this settion only

        $env:http_proxy = $null
        $env:https_proxy = $null
        $env:ftp_proxy = $null

        # Set PowerShell default proxy
        [System.Net.WebRequest]::DefaultWebProxy = $null

        Write-Host "Clear Auth Proxy User Environment"
        Write-Host ""
    }

}