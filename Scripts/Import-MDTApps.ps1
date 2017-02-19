<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Import-MDTApps.ps1 -Path "E:\MDTProduction" -ImportFolder "C:\Setup\MDTProduction\Applications"
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
Param(
    [parameter(mandatory=$True,Position=0)]
    [ValidateScript({Test-Path $_})] 
    $Path,

    [parameter(mandatory=$True,Position=1)]
    [ValidateScript({Test-Path $_})]
    $ImportFolder
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Throw
}

#Load the MDT PS Module
try
    {
        Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
    }
    catch
    {
        Write-Error 'The MDT PS module could not be loaded correctly, exit'
        BREAK
    }

if (!(test-path DS001:))
    {
         New-PSDrive -Name "MDT01" -PSProvider MDTProvider -Root $Path
    }

Function Import-MDTAppBulk{
        import-MDTApplication -path "MDT01:\Applications" `
        -enable "True"  `
        -Name $InstallLongAppName  `
        -ShortName $InstallLongAppName  `
        -Version ""  `
        -Publisher ""  `
        -Language ""  `
        -CommandLine $CommandLine  `
        -WorkingDirectory ".\Applications\$InstallLongAppName"  `
        -ApplicationSourcePath $InstallFolder  `
        -DestinationFolder $InstallLongAppName
}
$SearchFolders = get-childitem -Path $ImportFolder
Foreach ($SearchFolder in $SearchFolders){
    foreach ($InstallFile in (Get-ChildItem -Path $SearchFolder.FullName *.wsf)){
        $Install = $InstallFile.Name
        $InstallFolder = $InstallFile.DirectoryName
        $InstallLongAppName = $InstallFolder | Split-Path -Leaf
        $InstallerType = $InstallFilet.Extension
        $CommandLine = "cscript.exe $Install"
        Write-Verbose "Installer is $Install"
        Write-Verbose "InstallFolder is $InstallFolder"
        Write-Verbose "InstallLongAppName is $InstallLongAppName"
        Write-Verbose "InstallCommand is $CommandLine"
        Write-Verbose ""
        . Import-MDTAppBulk
    }
    foreach ($InstallFile in (Get-ChildItem -Path $SearchFolder.FullName *.exe)){
        $Install = $InstallFile.Name
        $InstallFolder = $InstallFile.DirectoryName
        $InstallLongAppName = $InstallFolder | Split-Path -Leaf
        $InstallerType = $InstallFilet.Extension
        $CommandLine = "$Install /q"
        Write-Verbose "Installer is $Install"
        Write-Verbose "InstallFolder is $InstallFolder"
        Write-Verbose "InstallLongAppName is $InstallLongAppName"
        Write-Verbose "InstallCommand is $CommandLine"
        Write-Verbose ""
        . Import-MDTAppBulk
    }
    foreach ($InstallFile in (Get-ChildItem -Path $SearchFolder.FullName *.msi)){
        $Install = $InstallFile.Name
        $InstallFolder = $InstallFile.DirectoryName
        $InstallLongAppName = $InstallFolder | Split-Path -Leaf
        $InstallerType = $InstallFilet.Extension
        $CommandLine = "msiexec.exe /i $Install /qn"
        Write-Verbose "Installer is $Install"
        Write-Verbose "InstallFolder is $InstallFolder"
        Write-Verbose "InstallLongAppName is $InstallLongAppName"
        Write-Verbose "InstallCommand is $CommandLine"
        Write-Verbose ""
        . Import-MDTAppBulk
    }
    foreach ($InstallFile in (Get-ChildItem -Path $SearchFolder.FullName *.msu)){
        $Install = $InstallFile.Name
        $InstallFolder = $InstallFile.DirectoryName
        $InstallLongAppName = $InstallFolder | Split-Path -Leaf
        $InstallerType = $InstallFilet.Extension
        $CommandLine = "wusa.exe $Install /Quiet /NoRestart"
        Write-Verbose "Installer is $Install"
        Write-Verbose "InstallFolder is $InstallFolder"
        Write-Verbose "InstallLongAppName is $InstallLongAppName"
        Write-Verbose "InstallCommand is $CommandLine"
        Write-Verbose ""
        . Import-MDTAppBulk

    }
    foreach ($InstallFile in (Get-ChildItem -Path $SearchFolder.FullName *.ps1)){
        $Install = $InstallFile.Name
        $InstallFolder = $InstallFile.DirectoryName
        $InstallLongAppName = $InstallFolder | Split-Path -Leaf
        $InstallerType = $InstallFilet.Extension
        $CommandLine = "PowerShell.exe -ExecutionPolicy ByPass -File $Install"
        Write-Verbose "Installer is $Install"
        Write-Verbose "InstallFolder is $InstallFolder"
        Write-Verbose "InstallLongAppName is $InstallLongAppName"
        Write-Verbose "InstallCommand is $CommandLine"
        Write-Verbose ""
        . Import-MDTAppBulk

    }
}
