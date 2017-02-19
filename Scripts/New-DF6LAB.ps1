<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-DF6LAB.ps1
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
Param()

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

# Check for Hyper-V Virtual Machine Management Service
Write-Host "Checking for Hyper-V Virtual Machine Management Service"
$Service = Get-Service -Name "Hyper-V Virtual Machine Management"
if ($Service.Status -ne "Running"){
    Write-Warning "Hyper-V Virtual Machine Management service not started, aborting script..."
    Break
}

Write-Host "Hyper-V Virtual Machine Management service running, OK, continuing..." -ForegroundColor Green
Write-Host ""

# Check for Internal Hyper-V Switch
Write-Host "Checking for Internal Hyper-V Virtual Machine switch"
$VMSwitchNameCheck = Get-VMSwitch | Where-Object -Property Name -EQ "Internal"
if (!($VMSwitchNameCheck.Name -eq "Internal"))
        {
        Write-Warning "Internal Hyper-V switch does not exist, aborting..."
        Break
        }

Write-Host "Internal Hyper-V Virtual Machine switch exist, OK, continuing..." -ForegroundColor Green
Write-Host ""

$VMLocation = "C:\VMs"
$HydrationISO = "C:\HydrationDF6\ISO\HydrationDF6.iso"

# Verify that Hydration ISO exist
if (!(Test-Path -path $HydrationISO)) {Write-Warning "Could not find Hydration ISO file aborting...";Break}

C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-DC01 -VMMem 1GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 100GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-MDT01 -VMMem 4GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 300GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-MDT02 -VMMem 4GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 300GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-WSUS01 -VMMem 4GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 300GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-GW01 -VMMem 1GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 100GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 2
# Windows 7 VMs must be Generation 1
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0001 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 1
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0002 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -ISO $HydrationISO -VMGeneration 1
# Create blank VMs for use in the guides
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0003 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0004 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0005 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0006 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0007 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-PC0008 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 2
# Ref Image VMs should be Generation 1
C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-REFW10X64-001 -VMMem 2GB -VMvCPU 2 -VMLocation $VMLocation -DiskMode Empty -EmptyDiskSize 60GB -VMSwitchName Internal -VMGeneration 1
