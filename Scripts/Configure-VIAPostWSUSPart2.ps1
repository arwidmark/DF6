<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Configure-VIAPostWSUSPart2.ps1    
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
    $ServerName = "localhost",

    [parameter(mandatory=$False,ValueFromPipelineByPropertyName=$true,Position=0)]
    $Port = "8530"
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

# Set WSUS Classifications
# Run "Get-WsusClassification" to get the Names and IDs
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "e6cf1350-c01b-414d-a61f-263d14d133b4"} | Set-WsusClassification #Critical Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "e0789628-ce08-4437-be74-2495b842f43b"} | Set-WsusClassification #Definition Updates
#Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "ebfc1fc5-71a4-4f7b-9aca-3b9a503104a0"} | Set-WsusClassification #Drivers
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "b54e7d24-7add-428f-8b75-90a396fa584f"} | Set-WsusClassification #Feature Packs
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "0fa1201d-4330-4fa8-8ae9-b877473b6441"} | Set-WsusClassification #Security Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "68c5b0a3-d1a6-4553-ae49-01d3a7827828"} | Set-WsusClassification #Service Packs
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "28bc880e-0592-4cbf-8f95-c79b17911d5f"} | Set-WsusClassification #Update Rollups
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "cd5ffd1e-e932-4e3a-bf74-18bf0b1bbd83"} | Set-WsusClassification #Updates

# Set WSUS Products
# Run "Get-WsusProduct" to get all products
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "8c3fcc84-7410-4a95-8b89-a166a0190486"} | Set-WsusProduct #Windows Defender
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "48ce8c86-6850-4f68-8e9d-7dc8535ced60"} | Set-WsusProduct #Developer Tools, Runtimes, and Redistributables
#Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "05eebf61-148b-43cf-80da-1c99ab0b8699"} | Set-WsusProduct #Windows 10 and later drivers
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "34f268b4-7e2d-40e1-8966-8bb6ea3dad27"} | Set-WsusProduct #Windows 10 and later upgrade & servicing drivers
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "a3c2375d-0c8a-42f9-bce0-28333e198407"} | Set-WsusProduct #Windows 10

# Run the initial Configuration (No Downloads)
Write-Verbose "Start Synchronization"
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.StartSynchronization()
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

#Decline superseeded updates
$SuperSeededUpdates = Get-WsusUpdate -Approval AnyExceptDeclined -Classification All -Status Any | Where-Object -Property UpdatesSupersedingThisUpdate -NE -Value 'None'
$SuperSeededUpdates | Deny-WsusUpdate
