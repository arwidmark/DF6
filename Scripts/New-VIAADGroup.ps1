<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAADGroup.ps1 -BaseOU $BaseOU -ADGroups $ADGroups
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
    $BaseOU,

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $ADGroups
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

foreach ($ADGroup in $ADGroups)
{
    $ADGroupName = $ADGroup.GroupName
    $ADGroupScope = $ADGroup.ADGroupScope
    $TargetOU = $ADGroup.OUPath
    $OUPath = $TargetOU + ",OU=" + $BaseOU + "," + $CurrentDomain.DistinguishedName
    Write-Verbose "ADGroupName: $ADGroupName"
    Write-Verbose "ADGroupScope: $ADGroupScope"    
    Write-Verbose "TargetOU: $TargetOU"
    Write-Verbose "OUPath: $OUPath"
    New-ADGroup -Name $ADGroupName -GroupScope $ADGroupScope -Path $OUPath -Server:$CurrentDomain.PDCEmulator
}



