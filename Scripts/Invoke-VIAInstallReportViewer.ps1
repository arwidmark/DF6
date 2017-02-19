<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Invoke-VIAInstallReportViewer.ps1 -Setup "C:\Setup\DL\Report_Viewer_2008_SP1\ReportViewer.exe"
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
    $Setup
 )

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

Try
    {
    Write-Verbose "Installing $Setup" 
    $sArgument = '/q'
    $Process = Start-Process $Setup -ArgumentList $sArgument -NoNewWindow -PassThru -Wait
    Write-Host "Process finished with return code: " $Process.ExitCode
    }
Catch
    {
      $ErorMsg = $_.Exception.Message
      Write-Warning "Error during script: $ErrorMsg"
      Break
    }
