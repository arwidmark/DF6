<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAMDTProductionDS.ps1 -Path "E:\MDTProduction" -Description "MDT Production" 
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
    $Description
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

#Set Variables
Write-Verbose "Starting"
$COMPUTERNAME = $Env:COMPUTERNAME
$RootDrive = $Env:SystemDrive
$ShareName = "\\" + $COMPUTERNAME + "\" + ($Path | Split-Path -Leaf) + "$"
Write-Verbose "Deployment Share Path: $Path"
Write-Verbose "Deployment Share Name: $ShareName"
Write-Verbose "Deployment Share Description: $Description"

# Create the MDT Build Lab Deployment Share root folder
New-Item -Path $Path -ItemType directory

# Create the MDT Build Lab Deployment Share
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "$Path" -Description $Description -NetworkPath $ShareName | add-MDTPersistentDrive
New-Item -Path "$Path\Branding" -ItemType directory
Write-Verbose "Change permissions for $Path"
New-SmbShare –Name (($Path | Split-Path -Leaf) + "$") –Path "$Path" –ChangeAccess EVERYONE
icacls.exe $Path\Captures /grant '"MDT_BA":(OI)(CI)(M)'

# Create MDT Logical Folders
New-Item -Path "DS002:\Operating Systems" -enable "True" -Name "Windows 10" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Task Sequences" -enable "True" -Name "Windows 10" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "WinPE x86" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "WinPE x64" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "Windows 10 x64" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "Windows 10 x64\NUC D54250WYK" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "Windows 10 x64\Surface Pro 3" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-Of-Box Drivers" -enable "True" -Name "Windows 10 x64\XPS 13 9343" -Comments "" -ItemType "folder"

# Create MDT Selection Profiles
New-Item -path "DS002:\Selection Profiles" -enable "True" -Name "WinPE x86" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x86`" /></SelectionProfile>" -ReadOnly "False"
New-Item -path "DS002:\Selection Profiles" -enable "True" -Name "WinPE x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x64`" /></SelectionProfile>" -ReadOnly "False"
