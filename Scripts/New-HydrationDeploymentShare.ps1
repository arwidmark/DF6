<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-HydrationDeploymentShare.ps1
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
param()

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

Write-Host "PowerShell runs elevated, OK, continuing..." -ForegroundColor Green
Write-Host ""

# Verify that MDT 2013 Update 1 is installed
if (!((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object -Property Displayname -like -Value "Microsoft Deployment Toolkit 2013 Update*").Displayname).count) {Write-Warning "MDT 2013 Update 1 is not installed, aborting...";Break}

# Verify that Windows ADK 10 is installed
if (!((Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object -Property Displayname -like -Value "Windows Assessment and Deployment Kit - Windows 10").Displayname).count) {Write-Warning "Windows ADK 10 is not installed, aborting...";Break}

# Check for downloaded files
if (!(Test-Path -path "C:\Setup\DL\Windows_Server_2012_R2\Setup.exe")) {Write-Warning "Could not find Windows Server 2012 R2 installation files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\Windows_7_SP1_Enterprise_x64\Setup.exe")) {Write-Warning "Could not find Windows 7 SP1 Enterprise x64 installation files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\BGInfo\BGInfo.exe")) {Write-Warning "Could not find BGInfo files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\NET_Framework_46\NDP46-KB3045557-x86-x64-AllOS-ENU.exe")) {Write-Warning "Could not find .NET Framework 4.6 files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2005\vcredist_x86.EXE")) {Write-Warning "Could not find Visual C++ 2005 x86 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2005\vcredist_x64.EXE")) {Write-Warning "Could not find Visual C++ 2005 x64 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2008\vcredist_x64.exe")) {Write-Warning "Could not find Visual C++ 2008 x86 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2008\vcredist_x86.exe")) {Write-Warning "Could not find Visual C++ 2008 x64 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2010\vcredist_x86.EXE")) {Write-Warning "Could not find Visual C++ 2010 x86 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2010\vcredist_x64.EXE")) {Write-Warning "Could not find Visual C++ 2010 x64 setup files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2012\vcredist_x64.exe")) {Write-Warning "Could not find Visual C++ 2012 x86 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2012\vcredist_x86.exe")) {Write-Warning "Could not find Visual C++ 2012 x64 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2013\vcredist_x86.EXE")) {Write-Warning "Could not find Visual C++ 2013 x86 setup files, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2013\vcredist_x64.EXE")) {Write-Warning "Could not find Visual C++ 2013 x64 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2015\vc_redist.x86.exe")) {Write-Warning "Could not find Visual C++ 2015 x86 setup file, aborting...";Break}
if (!(Test-Path -path "C:\Setup\DL\VC2015\vc_redist.x64.exe")) {Write-Warning "Could not find Visual C++ 2015 x64 setup file, aborting...";Break}

# Check memory on the host - Minimum is 16 GB 
Write-Host "Checking memory on the host - Minimum is 16 GB"
$NeededMemory = 16 #GigaBytes
$Memory = Get-WmiObject -Class Win32_ComputerSystem 
$MemoryInGB = [math]::round($Memory.TotalPhysicalMemory/1GB, 0)

if($MemoryInGB -lt $NeededMemory){
    
    Write-Warning "Oupps, you need at least $NeededMemory GB of memory"
    Write-Warning "Available memory on the host is $MemoryInGB GB"
    Write-Warning "Aborting script..."
    Break
}

Write-Host "Machine has $MemoryInGB GB memory, OK, continuing..." -ForegroundColor Green
Write-Host ""

# Check free space on C: - Minimum is 100 GB
$NeededFreeSpace = 60 #GigaBytes
$Disk = Get-wmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" 
$FreeSpace = [MATH]::ROUND($disk.FreeSpace /1GB)
Write-Host "Checking free space on C: - Minimum is $NeededFreeSpace GB"

if($FreeSpace -lt $NeededFreeSpace){
    
    Write-Warning "Oupps, you need at least $NeededFreeSpace GB of free disk space"
    Write-Warning "Available free space on C: is $FreeSpace GB"
    Write-Warning "Aborting script..."
    Break
}

Write-Host "Disk has $FreeSpace GB free space, OK, continuing..." -ForegroundColor Green
Write-Host ""

# Validation OK, create Hydration Deployment Share
$MDTServer = (Get-WmiObject win32_computersystem).Name

Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue 
New-Item -Path C:\HydrationDF6\DS -ItemType Directory -Force
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "C:\HydrationDF6\DS" -Description "Hydration DF6" -NetworkPath "\\$MDTServer\HydrationDF6$" | Add-MDTPersistentDrive
New-SmbShare –Name HydrationDF6$ –Path "C:\HydrationDF6\DS" –ChangeAccess EVERYONE

New-Item -Path C:\HydrationDF6\ISO\Content\Deploy -ItemType Directory -Force
New-Item -path "DS001:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "C:\HydrationDF6\ISO" -SelectionProfile "Everything" -SupportX86 "False" -SupportX64 "True" -GenerateISO "True" -ISOName "HydrationDF6.iso"
New-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "C:\HydrationDF6\ISO\Content\Deploy" -Description "Hydration DF6 Media" -Force

# Copy sample files to Hydration Deployment Share
Copy-Item -Path "C:\Setup\HydrationDF6\Source\Hydration\Applications" -Destination "C:\HydrationDF6\DS" -Recurse -Force
Copy-Item -Path "C:\Setup\HydrationDF6\Source\Hydration\Control" -Destination "C:\HydrationDF6\DS" -Recurse -Force
Copy-Item -Path "C:\Setup\HydrationDF6\Source\Hydration\Operating Systems" -Destination "C:\HydrationDF6\DS" -Recurse -Force
Copy-Item -Path "C:\Setup\HydrationDF6\Source\Hydration\Scripts" -Destination "C:\HydrationDF6\DS" -Recurse -Force
Copy-Item -Path "C:\Setup\HydrationDF6\Source\Media\Control" -Destination "C:\HydrationDF6\ISO\Content\Deploy" -Recurse -Force

# Copy downloaded applications
Copy-Item -Path "C:\Setup\DL\BGInfo\*" -Destination "C:\HydrationDF6\DS\Applications\Install - BGInfo\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2005" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2008" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2010" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2012" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2013" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\VC2015" -Destination "C:\HydrationDF6\DS\Applications\Install - Microsoft Visual C++ - x86-x64\Source" -Recurse -Force

# Copy downloaded operating systems
Copy-Item -Path "C:\Setup\DL\Windows_7_SP1_Enterprise_x64\*" -Destination "C:\HydrationDF6\DS\Operating Systems\W7SP1X64" -Recurse -Force
Copy-Item -Path "C:\Setup\DL\Windows_Server_2012_R2\*" -Destination "C:\HydrationDF6\DS\Operating Systems\WS2012R2" -Recurse -Force
