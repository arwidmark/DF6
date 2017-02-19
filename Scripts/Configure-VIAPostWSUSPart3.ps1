<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Configure-VIAPostWSUSPart3.ps1    
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

#Create the Default Approvel Rule
$CategoryCollection = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$ClassificationCollection = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$TargetgroupCollection = New-Object Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection

Write-Verbose "Define ViaMonstra Default Rule"
$ApprovalRule = "ViaMonstra Default Rule"
#$UpdateCategories = "Windows 10|Windows Defender|Developer Tools, Runtimes, and Redistributables"

Write-Verbose "Define Categories"
$UpdateCategories = "34f268b4-7e2d-40e1-8966-8bb6ea3dad27|8c3fcc84-7410-4a95-8b89-a166a0190486|a3c2375d-0c8a-42f9-bce0-28333e198407|48ce8c86-6850-4f68-8e9d-7dc8535ced60"

Write-Verbose "Define Classifications"
$UpdateClassifications = "Critical Updates|Security Updates|Definition Updates"

Write-Verbose "Define Computer Target Groups"
$ComputerTargetGroup = "All Computers"

Write-Verbose "Create ViaMonstra Default Rule"
$NewRule = $WSUSSrv.CreateInstallApprovalRule($ApprovalRule)

Write-Verbose "Get and add Categories"
$UpdateCategories = $WSUSSrv.GetUpdateCategories() | Where {  $_.Id -match $UpdateCategories}
$CategoryCollection.AddRange($updateCategories)
$NewRule.SetCategories($categoryCollection)

Write-Verbose "Get and add Classifications"
$UpdateClassifications = $WSUSSrv.GetUpdateClassifications() | Where { $_.Title -match $UpdateClassifications}
$ClassificationCollection.AddRange($updateClassifications )
$NewRule.SetUpdateClassifications($classificationCollection)

Write-Verbose "Get and add Computer Target Groups"
$TargetGroups = $WSUSSrv.GetComputerTargetGroups() | Where {$_.Name -Match $ComputerTargetGroup}
$TargetgroupCollection.AddRange($targetGroups)

Write-Verbose "Save and Enable $ApprovalRule"
$NewRule.SetComputerTargetGroups($targetgroupCollection)
$NewRule.Enabled = $True
$NewRule.Save()
