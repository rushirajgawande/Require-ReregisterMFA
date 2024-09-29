#Mandatory Need to connect Exchange Online and MSGraph
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Select User for Reregistering MFA")]
    $user
)
function Get-EXOMail {
    param (
        [Parameter(Mandatory = $true)]
        [string]$member
    )

    try {
        $memberEmail = (Get-mailbox -identity $member).primarySmtpAddress
        return $memberEmail
    }
    catch {
        Write-Error "Failed to get $member mail address from AD`n"
        $SRXEnv.ResultMessage += "Failed to get $member mail address from AD`n"
        return $false
    }
}

$memberEmail = Get-EXOMail -member $user
if ($memberEmail -eq $false) {
    Write-Host "Failed to get $user mail address from EXO"
    $srxEnv.ResultMessage += "Failed to get $user mail address from EXO`n"
    $errors = $false
    Exit 1
}
$AuthMethods = Get-MgUserAuthenticationMethod -UserId $memberEmail
ForEach ($AuthMethod in $AuthMethods){
    # if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.emailAuthenticationMethod"){
    #     try {            
    #         Remove-MgUserAuthenticationEmailMethod -UserId $memberEmail -EmailAuthenticationMethodId $AuthMethod.id
    #     }
    #     catch {
    #         Write-Host "Failed to remove Email Authentication Method`n"
    #         $srxEnv.ResultMessage += "Failed to remove Email Authentication Method`n"
    #         $errors = $true
    #     }
    # }
    if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"){
        try {
            Remove-MgUserAuthenticationMicrosoftAuthenticatorMethod -UserId $memberEmail -MicrosoftAuthenticatorAuthenticationMethodId $AuthMethod.id
        }
        catch {
            Write-Host "Failed to remove Microsoft Authenticator Authentication Method`n"
            $srxEnv.ResultMessage += "Failed to remove Microsoft Authenticator Authentication Method`n"
            $errors = $true
        }
    }
    if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.fido2AuthenticationMethod"){
        try {
            Remove-MgUserAuthenticationFido2Method -UserId $memberEmail -Fido2AuthenticationMethodId $AuthMethod.id
        }
        catch {
            Write-Host "Failed to remove Fido2 Authentication Method`n"
            $srxEnv.ResultMessage += "Failed to remove Fido2 Authentication Method`n"
            $errors = $true
        }
    }
    # if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod"){
    #     try {
    #         Remove-MgUserAuthenticationWindowsHelloForBusinessMethod -UserId $memberEmail -WindowsHelloForBusinessAuthenticationMethodId $AuthMethod.id
    #     }
    #     catch {
    #         write-host "Failed to remove Windows Hello For Business Authentication Method`n"
    #         $srxEnv.ResultMessage += "Failed to remove Windows Hello For Business Authentication Method`n"
    #         $errors = $true
    #     }
    # }
    if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.phoneAuthenticationMethod"){
        try {
            Remove-MgUserAuthenticationPhoneMethod -UserId $memberEmail -PhoneAuthenticationMethodId $AuthMethod.id
        }
        catch {
            Write-Host "Failed to remove Phone Authentication Method`n"
            $srxEnv.ResultMessage += "Failed to remove Phone Authentication Method`n"
            $errors = $true
        }
    }
    if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.temporaryAccessPassAuthenticationMethod"){
        try {
            Remove-MgUserAuthenticationTemporaryAccessPassMethod -UserId $memberEmail -TemporaryAccessPassAuthenticationMethodId $AuthMethod.id
        }
        catch {
            Write-Host "Failed to remove Temporary Access Pass Authentication Method`n"
            $srxEnv.ResultMessage += "Failed to remove Temporary Access Pass Authentication Method`n"
            $errors = $true
        }
    }
    # if ($AuthMethod.AdditionalProperties."@odata.type" -eq "#microsoft.graph.softwareOathAuthenticationMethod"){
    #     try {
    #         Remove-MgUserAuthenticationSoftwareOathMethod -UserId $memberEmail -SoftwareOathAuthenticationMethodId $AuthMethod.id
    #     }
    #     catch {
    #         Write-Host "Failed to remove Software Oath Authentication Method`n"
    #         $srxEnv.ResultMessage += "Failed to remove Software Oath Authentication Method`n"
    #         $errors = $true
    #     }
    # }    
}
