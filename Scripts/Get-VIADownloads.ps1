<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\setup\Scripts\Get-VIADownloads.ps1 -DLCSV (Import-Csv C:\setup\Settings\DF6.csv) -RootFolder C:\Setup\DL
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
    [parameter(position=0,mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $DLCSV,

    [parameter(position=1,mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $RootFolder
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

$TotalNumberOfObjects = $DLCSV.count
Write-Host "Downloading $TotalNumberOfObjects objects"
$Count = (0)

$Webclient = New-Object System.NET.Webclient

$DLCSV | ForEach-Object { 
#Read and Set Var
$Comment = $_.Comment
$FullName  = $_.FullName
$ShortName = $_.ShortName
$Source = $_.Source
$DestinationFolder = $_.DestinationFolder
$DestinationFile = $_.DestinationFile
$URL = $_.URL
$CommandType = $_.CommandType
$Command = $_.Command
$CommandLineSwitches = $_.CommandLineSwitches
$VerifyAfterCommand = $_.VerifyAfterCommand
$Count = ($Count + 1)
Write-Host "Working on $FullName ($Count/$TotalNumberOfObjects)"
Start-Sleep 1
$DestinationFolder = $RootFolder + "\" + $DestinationFolder
$Destination = $DestinationFolder + "\" + $DestinationFile
$Downloaded = Test-Path $Destination
    if($Downloaded -like 'True')
        {
        }
    else
        {
        Write-Host "$DestinationFile needs to be downloaded."
        Write-Host "Creating $DestinationFolder"
        New-Item -Path $DestinationFolder -ItemType Directory -Force | Out-Null
        Write-Host "I need $Source"
        Write-Host "Downloading $Destination"

        Try
            {
         #Start-BitsTransfer -Destination $Destination -Source $Source -Description "Download $FullName" -ErrorAction Continue
         $Webclient.DownloadFile( $Source, $Destination )

            }
            Catch
            {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Fail: $ErrorMessage"
            }
        }
}

# Start Proccessing downloaded files
Write-Host "Checking $TotalNumberOfObjects objects"
$Count = (0)

$DLCSV | ForEach-Object { 
#Read and Set Var
$Comment = $_.Comment
$FullName  = $_.FullName
$ShortName = $_.ShortName
$Source = $_.Source
$DestinationFolder = $_.DestinationFolder
$DestinationFile = $_.DestinationFile
$URL = $_.URL
$CommandType = $_.CommandType
$Command = $_.Command
$CommandLineSwitches = $_.CommandLineSwitches
$VerifyAfterCommand = $_.VerifyAfterCommand
if($CommandType -like 'NONE'){
}else{
 $Count = ($Count + 1)
 $DestinationFolder = $RootFolder + "\" + $DestinationFolder
 $Destination = $DestinationFolder + "\" + $DestinationFile
 $CheckFile = $DestinationFolder + "\" + $VerifyAfterCommand
 Write-Host "Working on $FullName ($Count/$TotalNumberOfObjects)"
 Write-Host "Looking for $CheckFile"
 $CommandDone = Test-Path $CheckFile
if($CommandDone -like 'True'){
 Write-Host "$FullName is already done"
}else{
 Write-Host "$FullName needs to be further processed."

#Selecting correct method to extract data 
Switch($CommandType){
EXEType01{
 $Command = $DestinationFolder + "\" + $Command
 $DownLoadProcess = Start-Process """$Command""" -ArgumentList ($CommandLineSwitches + " " + """$DestinationFolder""") -Wait
 $DownLoadProcess.HasExited
 $DownLoadProcess.ExitCode
}
NONE{
}
default{
}}}}}

