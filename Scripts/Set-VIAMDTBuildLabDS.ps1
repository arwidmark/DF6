<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Set-VIAMDTBuildLabDS.ps1 -Path "E:\MDTBuildLab"
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
    [Parameter(Mandatory=$False,Position=0)]
    $Path="E:\MDTBuildLab"
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

# Create the MDT Build Lab Deployment Share
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$Path"

#Update ControlFiles
Copy-Item "$RootDrive\Setup\MDTBuildLab\Control\Bootstrap.ini" "$Path\Control" -Force
Copy-Item "$RootDrive\Setup\MDTBuildLab\Control\CustomSettings.ini" "$Path\Control" -Force

Write-Verbose "updating Bootstrap.ini"
$Bootstrap = "$Path\Control\Bootstrap.ini"
foreach ($str in $Bootstrap) 
    {
    $content = Get-Content -path $str
    $content | foreach {$_ -replace "rUserDomain", $env:USERDOMAIN} | Set-Content $str
}

foreach ($str in $Bootstrap) 
    {
    $content = Get-Content -path $str
    $content | foreach {$_ -replace "rDeployRoot", (Get-ItemProperty -Path DS001: -Name UNCPATH).UNCPATH} | Set-Content $str
}

#Set Properties for WinPE
Set-ItemProperty -Path DS001: -Name Boot.x86.LiteTouchWIMDescription -Value 'MDT Build Lab x86'
Set-ItemProperty -Path DS001: -Name Boot.x86.LiteTouchISOName -Value 'MDT Build Lab x86.iso'
Set-ItemProperty -Path DS001: -Name Boot.x64.LiteTouchWIMDescription -Value 'MDT Build Lab x64'
Set-ItemProperty -Path DS001: -Name Boot.x64.LiteTouchISOName -Value 'MDT Build Lab x64.iso'
Set-ItemProperty -Path DS001: -Name SupportX86 -Value 'True'
Set-ItemProperty -Path DS001: -Name SupportX64 -Value 'True'
Set-ItemProperty -Path DS001: -Name Boot.x86.SelectionProfile -Value 'Nothing'
Set-ItemProperty -Path DS001: -Name Boot.x86.IncludeAllDrivers -Value 'True'
Set-ItemProperty -Path DS001: -Name Boot.x86.IncludeNetworkDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x86.IncludeMassStorageDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x86.IncludeVideoDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x86.IncludeSystemDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x64.SelectionProfile -Value 'Nothing'
Set-ItemProperty -Path DS001: -Name Boot.x64.IncludeAllDrivers -Value 'True'
Set-ItemProperty -Path DS001: -Name Boot.x64.IncludeNetworkDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x64.IncludeMassStorageDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x64.IncludeVideoDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x64.IncludeSystemDrivers -Value 'False'
Set-ItemProperty -Path DS001: -Name Boot.x86.FeaturePacks -Value ''
Set-ItemProperty -Path DS001: -Name Boot.x64.FeaturePacks -Value '' 
Set-ItemProperty -Path DS001: -Name Boot.x64.GenerateLiteTouchISO -Value 'False'

Get-ItemProperty -Path DS001: -Name Boot.x86.FeaturePacks
Get-ItemProperty -Path DS001: -Name Boot.x64.FeaturePacks
