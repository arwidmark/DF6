<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAMDTBuildLabDS.ps1 -Path "E:\MDTBuildLab" -Description "MDT Build Lab"
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
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$Path" -Description $Description -NetworkPath $ShareName | add-MDTPersistentDrive
Write-Verbose "Change permissions for $Path"
New-SmbShare –Name (($Path | Split-Path -Leaf) + "$") –Path "$Path" –ChangeAccess EVERYONE
icacls.exe $Path /grant '"MDT_BA":(OI)(CI)(RX)'
icacls.exe $Path\Captures /grant '"MDT_BA":(OI)(CI)(M)'

# Create MDT Logical Folders
New-Item -Path "DS001:\Operating Systems" -enable "True" -Name "Windows 10" -Comments "" -ItemType "folder"
New-Item -Path "DS001:\Task Sequences" -enable "True" -Name "Reference Task Sequences" -Comments "" -ItemType "folder"
New-Item -Path "DS001:\Packages" -enable "True" -Name "Windows 10 x86" -Comments "" -ItemType "folder"
New-Item -Path "DS001:\Packages" -enable "True" -Name "Windows 10 x64" -Comments "" -ItemType "folder"

# Create MDT Selection Profiles
New-Item -path "DS001:\Selection Profiles" -enable "True" -Name "Windows 10 x86 Packages" -Comments "" -Definition "<SelectionProfile><Include path=`"Packages\Windows 10 x86`" /></SelectionProfile>" -ReadOnly "False"
New-Item -path "DS001:\Selection Profiles" -enable "True" -Name "Windows 10 x64 Packages" -Comments "" -Definition "<SelectionProfile><Include path=`"Packages\Windows 10 x86`" /></SelectionProfile>" -ReadOnly "False"



