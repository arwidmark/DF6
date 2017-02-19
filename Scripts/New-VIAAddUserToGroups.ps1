<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAAddUserToGroups.ps1 -BaseOU $BaseOU -AccountNames $AccountNames -Verbose
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
    [parameter(Position=0,mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    $BaseOU,

    [parameter(Position=1,mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $AccountNames
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}
$CurrentDomain = Get-ADDomain

foreach ($AccountName in $AccountNames)
{
    $Name = $AccountName.UserName
    $Groups = $AccountName.MemberOf
        
    foreach ($Group in $Groups)
    {
        $TargetGroup = Get-AdGroup -Filter "Name -like '$Group'"
        $TargetAccount = Get-AdUser -Filter "SamAccountName -like '$Name'"
        $TargetGroup
        $TargetAccount

        Write-Verbose "Adding $TargetAccount to $TargetGroup"
        
        Add-ADGroupMember -Identity $TargetGroup -Members $TargetAccount -Server $CurrentDomain.PDCEmulator
    }
}
