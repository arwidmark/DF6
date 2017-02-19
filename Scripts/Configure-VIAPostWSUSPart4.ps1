<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Configure-VIAPostWSUSPart4.ps1    
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

$ApprovalRule = "ViaMonstra Default Rule"
Write-Verbose "Save and Enable $ApprovalRule"
$ViaRule = $WSUSSrv.GetInstallApprovalRules() | Where {  $_.Name -match "$ApprovalRule"} | Where {  $_.Enabled -match 'True'}
$ViaRule.ApplyRule()
