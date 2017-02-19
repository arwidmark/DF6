<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\CreateNew-VM.ps1 -VMName DF6-DC01 -VMMem 1GB -VMvCPU 2 -VMLocation C:\VMs -DiskMode Empty -EmptyDiskSize 100GB -VMSwitchName Internal -ISO C:\Setup\ISO\HydrationDF6.iso -VMGeneration 2
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
    [Parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [String]
    $VMName,

    [Parameter(mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    #[Int]
    $VMMem = 1GB,

    [Parameter(mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $VMvCPU = 1,
    
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [String]
    $VMLocation = "C:\VMs",

    [parameter(mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $VHDFile,

    [parameter(mandatory=$True)]
    [ValidateSet("Copy","Diff","Empty")]
    [String]
    $DiskMode = "Copy",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [String]
    $VMSwitchName,

    [parameter(mandatory=$False)]
    [ValidateNotNullOrEmpty()]
    [Int]
    $VlanID,

    [parameter(mandatory=$False)]
    [ValidateSet("1","2")]
    [Int]
    $VMGeneration,

    [parameter(mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ISO,

    [parameter(mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    $EmptyDiskSize
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

# Check Build Version
# Due to a minor bug in the Hyper-V module 2.0 we need to replace that with the old version when creating VM's that uses Add-VMDvdDrive
if($PSVersionTable.BuildVersion.Major -eq 10){
    Write-Output "Note: Running on $($PSVersionTable.BuildVersion) and therefore we need to change to Hyper-V module 1.1"
    Write-Output "Unloading Hyper-V module 2.0 and loading Hyper-V module 1.1"
    Remove-Module Hyper-V -Force
    Import-Module Hyper-v -RequiredVersion 1.1 -Force
    Get-Module -Name Hyper-V
    }

#Create VM 
$VM = New-VM -Name $VMName -MemoryStartupBytes $VMMem -Path $VMLocation -NoVHD -Generation $VMGeneration
Remove-VMNetworkAdapter -VM $VM

#Add Networkadapter
if($VMNetWorkType -eq "Legacy" -and $VMGeneration -eq "1")
    {
        Add-VMNetworkAdapter -VM $VM -SwitchName $VMSwitchName -IsLegacy $true
    }
else
    {
        Add-VMNetworkAdapter -VM $VM -SwitchName $VMSwitchName
    }




#Set vCPU
if($VMvCPU -ne "1")
    {
        Set-VMProcessor -Count $VMvCPU -VM $VM
    }

#Set VLAN
If($VlanID -ne $NULL){
    Set-VMNetworkAdapterVlan -VlanId $VlanID -Access -VM $VM
}

#Add Virtual Disk
switch ($DiskMode)
{
    Copy {
        New-Item "$VMLocation\$VMName\Virtual Hard Disks" -ItemType directory -Force
        $VHD = $VHDFile | Split-Path -Leaf
        Copy-Item $VHDFile -Destination "$VMLocation\$VMName\Virtual Hard Disks\"
        Add-VMHardDiskDrive -VM $VM -Path "$VMLocation\$VMName\Virtual Hard Disks\$VHD"
    }
    Diff {
        New-Item "$VMLocation\$VMName\Virtual Hard Disks" -ItemType directory -Force
        $VHD = $VHDFile | Split-Path -Leaf
        New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VHD" -ParentPath $VHDFile -Differencing
        Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VHD"
    }
    Empty{
        $VHD = $VMName + ".vhdx"
        New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VHD" -SizeBytes $EmptyDiskSize -Dynamic
        Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VHD"
    }
    Default {Write-Error "Epic Failure";throw}
}

#Add DVD for Gen2
if($VMGeneration -ne "1"){
    Add-VMDvdDrive -VMName $VMName
    }

#Mount ISO
if($ISO -ne ''){
    Set-VMDvdDrive -VMName $VMName -Path $ISO
    }

#Set Correct Bootorder for Gen 2
if($VMGeneration -ne "1")
    {
        $VMDvdDrive = Get-VMDvdDrive -VMName $VMName
        $VMHardDiskDrive = Get-VMHardDiskDrive -VM $VM
        $VMNetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
        Set-VMFirmware -VM $VM -BootOrder $VMDvdDrive,$VMHardDiskDrive,$VMNetworkAdapter
    }

if($PSVersionTable.BuildVersion.Major -eq 10){
    Write-Output "Note: Running on $($PSVersionTable.BuildVersion) and therefore we need to change back to Hyper-V module 2.0"
    Write-Output "Unloading Hyper-V module 1.1 and loading Hyper-V module 2.0"
    Remove-Module Hyper-V -Force
    Import-Module Hyper-v 
    Get-Module -Name Hyper-V
    }
