<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Invoke-VIAInstallADK.ps1 -Setup C:\Setup\DL\Windows_ADK_10\adksetup.exe -Role MDT
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
Param (
    [Parameter(Mandatory=$true,Position=0)]
    $Setup,

    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet("Full","MDT","SCCM","SCVM")]
    $Role = "MDT"
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

switch ($Role)
{
    SCVM
    {
    try
        {
        #Install ADK
        Write-Output "Install for $Role"
        $sArgument = " /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool /norestart /quiet /ceip off"
        $Process = Start-Process $Setup -ArgumentList $sArgument -NoNewWindow -PassThru -Wait
        Write-Host "Process finished with return code: " $Process.ExitCode
        }
    Catch
        {
          $ErorMsg = $_.Exception.Message
          Write-Warning "Error during script: $ErrorMsg"
          Break
        }
    }
    MDT
    {
    try
        {
        #Install ADK
        Write-Output "Install for $Role"
        $sArgument = " /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool /norestart /quiet /ceip off"
        $Process = Start-Process $Setup -ArgumentList $sArgument -NoNewWindow -PassThru -Wait
        Write-Host "Process finished with return code: " $Process.ExitCode
        #Test-Path -Path 'HKLM:\software\wow6432node\microsoft\windows\currentversion\uninstall\{e9e06304-a604-434b-b35f-d9beb94dc06d}'
        }
    Catch
        {
          $ErorMsg = $_.Exception.Message
          Write-Warning "Error during script: $ErrorMsg"
          Break
        }
    }
    Default
    {
    }
}