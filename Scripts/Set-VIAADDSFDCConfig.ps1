<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Set-VIAADDSFDCConfig.ps1 -Password "P@ssw0rd" -FQDN "corp.viamonstra.com" -NetBiosDomainName "VIAMONSTRA"
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
Param(
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $Password,
    
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $FQDN,
    
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $NetBiosDomainName
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

Write-Verbose $Password
Write-Verbose $FQDN
Write-Verbose $NetBiosDomainName

# Setting variables
$DatabaseRoot = "C:\Windows"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Configure Active Directory and DNS
Write-host (get-date -Format u)" - Configure Active Directory and DNS"
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "$DatabaseRoot\NTDS" `
-DomainMode "WIN2012R2" `
-DomainName $FQDN `
-DomainNetbiosName $NetBiosDomainName `
-ForestMode "WIN2012R2" `
-InstallDns:$true `
-SafeModeAdministratorPassword $SecurePassword `
-LogPath "$DatabaseRoot\NTDS" `
-NoRebootOnCompletion:$true `
-SysvolPath "$DatabaseRoot\SYSVOL" `
-Force:$true
