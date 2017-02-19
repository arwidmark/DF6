<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIADFSReplica.ps1 -GroupName MDT -FolderName MDTProduction –SourceComputer MDT01 -DestinationComputer MDT02 -SourceFolder E:\MDTProduction -DestinationFolder E:\MDTProduction –Verbose
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
Param
(
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $GroupName = "MDT",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $FolderName = "MDTProduction",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $SourceComputer = "MDT01",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $DestinationComputer = "MDT02",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $SourceFolder = "E:\MDTProduction",

    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $DestinationFolder = "E:\MDTProduction"
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

#Create replication group and name
New-DfsReplicationGroup -GroupName $GroupName
New-DfsReplicatedFolder -FolderName $FolderName -GroupName $GroupName

#Add DFS members at replica folder for Source
Add-DfsrMember -ComputerName $SourceComputer -GroupName $GroupName
Set-DfsReplicatedFolder -GroupName $GroupName -FolderName $FolderName

#Add DFS members at replica folder for Source
Add-DfsrMember -ComputerName $DestinationComputer -GroupName $GroupName
Set-DfsReplicatedFolder -GroupName $GroupName -FolderName $FolderName

#Configures membership settings
Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ContentPath $SourceFolder -ComputerName $SourceComputer -PrimaryMember:$true -StagingPathQuotaInMB 20480 -ConflictAndDeletedQuotaInMB 8192 -Force
Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ContentPath $DestinationFolder -ComputerName $DestinationComputer -StagingPathQuotaInMB 20480 -ConflictAndDeletedQuotaInMB 8192 -Force #-ReadOnly

#Creates a connection between members of a replication group
Add-DfsrConnection -GroupName $GroupName -SourceComputerName $SourceComputer -DestinationComputerName $DestinationComputer

#Configures membership settings
Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ComputerName $DestinationComputer -ReadOnly:$True -Force

#Initiates an update of the DFS Replication service.
Update-DfsrConfigurationFromAD -ComputerName "$SourceComputer"
Update-DfsrConfigurationFromAD -ComputerName "$DestinationComputer"
