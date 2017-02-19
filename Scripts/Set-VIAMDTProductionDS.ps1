<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\setup\Scripts\Set-VIAMDTProductionDS.ps1 -Path "E:\MDTProduction"
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
    $Path
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
New-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "$Path"

#Update ControlFiles
Copy-Item "$RootDrive\Setup\MDTProduction\Branding" "$Path" -Force -Recurse
Copy-Item "$RootDrive\Setup\MDTProduction\Control" "$Path" -Force -Recurse
Copy-Item "$RootDrive\Setup\MDTProduction\Scripts" "$Path" -Force -Recurse

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
    $content | foreach {$_ -replace "rDeployRoot", "\\$COMPUTERNAME\MDTProduction$"} | Set-Content $str
}

#Set Global Properties for WinPE
Set-ItemProperty -Path DS002: -Name SupportX86 -Value 'True'
Set-ItemProperty -Path DS002: -Name SupportX64 -Value 'True'

#Set x86 Properties for WinPE
Set-ItemProperty -Path DS002: -Name Boot.x86.LiteTouchWIMDescription -Value 'MDT Production x86'
Set-ItemProperty -Path DS002: -Name Boot.x86.LiteTouchISOName -Value 'MDT Production x86.iso'
Set-ItemProperty -Path DS002: -Name Boot.x86.IncludeAllDrivers  -Value 'True'
Set-ItemProperty -Path DS002: -Name Boot.x86.BackgroundFile  -Value '%DEPLOYROOT%\Branding\ViaMonstraLogo.bmp'
Set-ItemProperty -Path DS002: -Name Boot.x86.GenerateGenericWIM  -Value 'False'
Set-ItemProperty -Path DS002: -Name Boot.x86.GenerateGenericISO  -Value 'False'
Set-ItemProperty -Path DS002: -Name Boot.x86.GenerateLiteTouchISO  -Value 'True'
Set-ItemProperty -Path DS002: -Name Boot.x86.SelectionProfile  -Value 'WinPE x86'
Set-ItemProperty -Path DS002: -Name Boot.x86.FeaturePacks  -Value 'winpe-dismcmdlets,winpe-mdac,winpe-netfx,winpe-powershell,winpe-securebootcmdlets,winpe-storagewmi'

#Set x64 Properties for WinPE
Set-ItemProperty -Path DS002: -Name Boot.x64.LiteTouchWIMDescription -Value 'MDT Production x64'
Set-ItemProperty -Path DS002: -Name Boot.x64.LiteTouchISOName -Value 'MDT Production x64.iso'
Set-ItemProperty -Path DS002: -Name Boot.x64.IncludeAllDrivers  -Value 'True'
Set-ItemProperty -Path DS002: -Name Boot.x64.BackgroundFile  -Value '%DEPLOYROOT%\Branding\ViaMonstraLogo.bmp'
Set-ItemProperty -Path DS002: -Name Boot.x64.GenerateGenericWIM  -Value 'False'
Set-ItemProperty -Path DS002: -Name Boot.x64.GenerateGenericISO  -Value 'False'
Set-ItemProperty -Path DS002: -Name Boot.x64.GenerateLiteTouchISO  -Value 'True'
Set-ItemProperty -Path DS002: -Name Boot.x64.SelectionProfile  -Value 'WinPE x64'
Set-ItemProperty -Path DS002: -Name Boot.x64.FeaturePacks  -Value 'winpe-dismcmdlets,winpe-mdac,winpe-netfx,winpe-powershell,winpe-securebootcmdlets,winpe-storagewmi'
