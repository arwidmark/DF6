<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Set-VIARRASNetworking.ps1 -InternalIP "192.168.1.1"
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
    [parameter(Position=0,mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $InternalIP = "192.168.1.1"
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

Write-Verbose "Configure RRAS"

$InternalInterfaceName = (Get-NetIPAddress -IPAddress "$InternalIP" -ErrorAction Stop).InterfaceAlias
$ExternalInterface = Get-NetAdapter | Where-Object -Property InterfaceAlias -NE -Value $InternalInterfaceName
$ExternalInterfaceName = $ExternalInterface.Name

Write-Verbose "Internal Network Adapter is: $InternalInterfaceName"
Write-Verbose "External Network Adapter is: $ExternalInterfaceName"

cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface ""$ExternalInterfaceName"""
cmd.exe /c "netsh routing ip nat set interface ""$ExternalInterfaceName"" mode=full"
cmd.exe /c "netsh routing ip nat add interface ""$InternalInterfaceName"""
