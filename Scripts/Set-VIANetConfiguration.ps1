<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Set-VIANetConfiguration.ps1
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
    [parameter(mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    $IPAddress,

    [parameter(mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    $PrefixLength,

    [parameter(mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=2)]
    [ValidateNotNullOrEmpty()]
    $DefaultGateway,

    [parameter(mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=3)]
    [ValidateNotNullOrEmpty()]
    $DNSServer
)

$NetAdapter = Get-NetAdapter
New-NetIPAddress  -IPAddress $IPAddress -AddressFamily IPv4 -PrefixLength $PrefixLength -InterfaceAlias $NetAdapter.ifAlias -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceAlias $NetAdapter.ifAlias -ServerAddresses $DNSServer

