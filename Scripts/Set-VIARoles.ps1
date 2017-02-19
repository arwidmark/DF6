<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Set-VIARoles.ps1 -Role DHCP
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

[CmdletBinding(DefaultParameterSetName='Param Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$true)]
Param
(
    [parameter(mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("FILE","RDGW","ADDS","DHCP","RRAS","RDGW","MGMT","DEPL","ADCA","WSUS","SCVM")]
    $Role,

    [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Path
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

Function Invoke-Exe{
    [CmdletBinding(SupportsShouldProcess=$true)]

    param(
        [parameter(mandatory=$true,position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Executable,

        [parameter(mandatory=$true,position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Arguments,

        [parameter(mandatory=$false,position=2)]
        [ValidateNotNullOrEmpty()]
        [int]
        $SuccessfulReturnCode = 0
    )

    Write-Verbose "Running $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru"
    $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru

    Write-Verbose "Returncode is $($ReturnFromEXE.ExitCode)"

    if(!($ReturnFromEXE.ExitCode -eq $SuccessfulReturnCode)) {
        throw "$Executable failed with code $($ReturnFromEXE.ExitCode)"
    }
}


switch ($Role)
{    
    DHCP
    {
        #Action
        $Action = "Authorize the DHCP Server"
        Write-Output "Action: $Action"
        Add-DhcpServerInDC
        Start-Sleep 2

        #Action
        $Action = "Add Security Groups"
        Write-Output "Action: $Action"
        Add-DhcpServerSecurityGroup
        Start-Sleep 2

        #Action
        $Action = "Making the ServerManager happy (Flag DHCP as configured)"
        Write-Output "Action: $Action"
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2 -Force
        Start-Sleep 2

        #Action
        $Action = "Restart Service"
        Write-Output "Action: $Action"
        Restart-Service "DHCP Server" -Force
        Start-Sleep 2
    }
    DEPL
    {
        Write-Verbose "Configure role for $Role"
        Invoke-Exe -Executable wdsutil.exe -Arguments "/Initialize-Server /REMINST:$Path /Authorize"
        Invoke-Exe -Executable wdsutil.exe -Arguments "/Set-Server /AnswerClients:All"
        Get-Service -Name WDSServer | Start-Service
    }
    WSUS
    {
        Write-Output "Configure role for $Role"
        $Setup = 'C:\Program Files\Update Services\Tools\WsusUtil.exe'
        $Argument = "PostInstall SQL_INSTANCE_NAME=$ENV:ComputerName\SQLEXPRESS CONTENT_DIR=$Path"
        Start-Process -FilePath $Setup -ArgumentList $Argument -Wait -NoNewWindow
    }
    Default
    {
        Write-Warning "Nothing to do for role $Role"
    }
}
