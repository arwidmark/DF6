<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Invoke-VIAInstallMDT.ps1 -Setup C:\Setup\DL\MDT_2013_U2\MicrosoftDeploymentToolkit2013_x64.msi -Role Full
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
    [ValidateSet("Full")]
    $Role = "Full"
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
    Full
    {
    try
        {
        #Install MDT
        Write-Output "Install for $Role"
        $sArgument = " /i $Setup /qb"
        $Process = Start-Process msiexec.exe -ArgumentList $sArgument -NoNewWindow -PassThru -Wait
        Write-Host "Process finished with return code: " $Process.ExitCode
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
