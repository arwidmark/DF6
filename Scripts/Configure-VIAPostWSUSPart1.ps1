<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Configure-VIAPostWSUSPart1.ps1
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

[CmdletBinding(SupportsShouldProcess=$true,PositionalBinding=$true)]
Param
(
    [parameter(mandatory=$False,ValueFromPipelineByPropertyName=$true,Position=0)]
    $ServerName = 'localhost',

    [parameter(mandatory=$False,ValueFromPipelineByPropertyName=$true,Position=0)]
    $Port = '8530'
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

$WSUSSrv = Get-WSUSServer -Name $ServerName -Port $Port
$WSUSSrvCFG = $WSUSSrv.GetConfiguration()
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()

#Set WSUS to download from MU
Set-WsusServerSynchronization -SyncFromMU

# Choose Languages
Write-Verbose "Setting UpdateLanguage to 'en'"
$WSUSSrvCFG = $WSUSSrv.GetConfiguration()
$WSUSSrvCFG.AllUpdateLanguagesEnabled = $false
$WSUSSrvCFG.AllUpdateLanguagesDssEnabled = $false
$WSUSSrvCFG.SetEnabledUpdateLanguages('en')
$WSUSSrvCFG.Save()

# Remove All Products and Classifications
Write-Verbose 'Disable all Classifications and all Products'
Get-WsusClassification | Set-WsusClassification -Disable
Get-WsusProduct | Set-WsusProduct -Disable

# Run the initial Configuration (No Downloads)
Write-Verbose 'Start Synchronization (For Category Only)'
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.StartSynchronizationForCategoryOnly()            
While($WSUSSrvSubScrip.GetSynchronizationStatus() -ne 'NotProcessing') 
{   
    $TotalItems = $($WSUSSrvSubScrip.GetSynchronizationProgress().TotalItems)
    $ProcessedItems = $($WSUSSrvSubScrip.GetSynchronizationProgress().ProcessedItems)
    if($ProcessedItems -eq 0){
    Write-Progress -id 1 -Activity "$($WSUSSrvSubScrip.GetSynchronizationProgress().Phase)" -PercentComplete 0
    }
    else
    {
    $PercentComplete = $ProcessedItems/$TotalItems*100
    Write-Progress -id 1 -Activity "$($WSUSSrvSubScrip.GetSynchronizationProgress().Phase)" -PercentComplete $PercentComplete
    }
} 

#Set Sync Auto
Write-Verbose 'Set Sync to Auto'
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.SynchronizeAutomatically=$True

#Note: The time is in GMT
Write-Verbose 'Set Sync at 20:00:00 and 3 times per day'
$WSUSSrvSubScrip.SynchronizeAutomaticallyTimeOfDay='20:00:00'
$WSUSSrvSubScrip.NumberOfSynchronizationsPerDay='3'
$WSUSSrvSubScrip.Save()
