<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAADStructure.ps1 -BaseOU $BaseOU -OUs $OUs
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

[cmdletbinding(SupportsShouldProcess=$true)]
Param(
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $BaseOU,

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $OUs
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

# Settinga variables
$CurrentDomain = Get-ADDomain

foreach ($OU in $OUs)
{
    $OUName = $OU.Name
    $OUPath = $OU.Path
    
    If($OUPath -eq "")
    {
        Write-Verbose "Creating $OUName in OU=$BaseOU,$CurrentDomain"
        New-ADOrganizationalUnit -Name:$OUName -Path:"OU=$BaseOU,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
    }
    else
    {
        Write-Verbose "Creating $OUName in $OUPath,OU=$BaseOU,$CurrentDomain"
        New-ADOrganizationalUnit -Name:$OUName -Path:"$OUPath,OU=$BaseOU,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
    }
}

