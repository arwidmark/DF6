<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAServiceAccount.ps1 -AccountName MDT_WS -AccountDescription "MDT Web Service Account" -AccountType ServiceAccount -Password "P@ssw0rd"
.NOTES
    Created:	 2015-12-15
    Version:	 1.0

    Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

    Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com

    Disclaimer:
    This script is provided "AS IS" with no warranties, confers no rights and 
    is not supported by the authors or Deployment Artist.
.LINK
    http://www.deploymentfundamentals.com
#>

[cmdletbinding(SupportsShouldProcess=$True)]
Param
(
[parameter(mandatory=$true,HelpMessage="Please, provide a name.")]
    [ValidateNotNullOrEmpty()]
    $AccountName,
[parameter(mandatory=$true,HelpMessage="Please, provide a description.")]
    [ValidateNotNullOrEmpty()]
    $AccountDescription,
[parameter(mandatory=$true,HelpMessage="Please, provide ServiceAccount or AdminAccount")]
    [ValidateSet("ServiceAccount","AdminAccount")]
    $AccountType,
[parameter(mandatory=$true,HelpMessage="Please, provide the password to be used.")]
    [ValidateNotNullOrEmpty()]
    $Password
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

$CurrentDomain = Get-ADDomain
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

Switch ($AccountType)
{
ServiceAccount{
    New-ADUser -Description:$AccountDescription -DisplayName:$AccountName -GivenName:$AccountName -Name:$AccountName -Path:"OU=Service Accounts,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -SamAccountName:$AccountName
    $NewAccount = Get-ADUser $AccountName
    Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
    Set-ADAccountControl $NewAccount -CannotChangePassword:$true -PasswordNeverExpires:$true
    Set-ADUser $NewAccount -ChangePasswordAtLogon:$False 
    Enable-ADAccount $NewAccount
    }
AdminAccount{
    New-ADUser -Description:$AccountDescription -DisplayName:$AccountName -GivenName:$AccountName -Name:$AccountName -Path:"OU=Admin Accounts,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -SamAccountName:$AccountName
    $NewAccount = Get-ADUser $AccountName
    Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
    Set-ADAccountControl $NewAccount -CannotChangePassword:$false -PasswordNeverExpires:$true
    Set-ADUser $NewAccount -ChangePasswordAtLogon:$False 
    Enable-ADAccount $NewAccount
    }
} 



