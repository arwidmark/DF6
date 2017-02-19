<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAMDTMigDataShare.ps1 -Path "E:\MigData" -BuildAccount "MDT_BA"
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
Param (
    [Parameter(Mandatory=$True,Position=0)]
    $Path,

    [Parameter(Mandatory=$True,Position=1)]
    $BuildAccount
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

# Create the MDT Build Lab Deployment Share root folder
New-Item -Path "$Path" -ItemType directory
Write-Verbose "Change permissions for $Path usinmg Icacls.exe"
New-SmbShare –Name (($Path | Split-Path -Leaf) + "$") –Path "$Path" –ChangeAccess EVERYONE
icacls.exe $Path /grant ($BuildAccount + ":(OI)(CI)(M)")
