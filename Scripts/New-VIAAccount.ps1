<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\New-VIAAccount.ps1 -BaseOU $BaseOU -AccountNames $AccountNames
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
    [parameter(mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $BaseOU,

    [parameter(mandatory=$True)]
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

Function New-RandomPassword
    {
    param([int]$PasswordLength,[boolean]$Complex)

    #Characters to use based
    $strSimple = "A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z” 
    $strComplex = "A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z”,"!","_" 
    $strNumbers = "2","3","4","5","6","7","8","9","0"
     
    #Check to see if password contains at least 1 digit
    $bolHasNumber = $false
    $pass = $null
     
    #Sets which Character Array to use based on $Complex
    if ($Complex){$strCharacters = $strComplex}else{$strCharacters = $strSimple}
   
    #Loop to actually generate the password
    for ($i=0;$i -lt $PasswordLength; $i++){$c = Get-Random -InputObject $strCharacters
     if ([char]::IsDigit($c)){$bolHasNumber = $true}$pass += $c}
    
    #Check to see if a Digit was seen, if not, fixit
    if ($bolHasNumber)
        {
            return $pass
        }
        else
        {
            $pos = Get-Random -Maximum $PasswordLength
            $n = Get-Random -InputObject $strNumbers
            $pwArray = $pass.ToCharArray()
            $pwArray[$pos] = $n
            $pass = ""
            foreach ($s in $pwArray)
            {
                $pass += $s
            }
        return $pass
    }
}
$ArrayDataToReturn = @{}

$CurrentDomain = Get-ADDomain
foreach ($AccountName in $AccountNames)
{
        $ADAccountType = $AccountName.AccountType
        If($ADAccountType -eq "AdminAccount")
            {
            $ADAccountName = $AccountName.UserName
            $AccountDescription = $AccountName.Description
            $OUPath = $AccountName.OUPath
            $TargetOU = $OUPath + ",OU=" + $BaseOU + "," + $CurrentDomain.DistinguishedName
            $Password = $AccountName.PW
            $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
            New-ADUser `
            -Description $AccountDescription `
            -DisplayName $ADAccountName `
            -GivenName $ADAccountName `
            -Name $ADAccountName `
            -Path $TargetOU `
            -SamAccountName $ADAccountName `
            -CannotChangePassword $false `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $False
            $NewAccount = Get-ADUser $ADAccountName
            Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
            #Set-ADAccountControl $NewAccount -CannotChangePassword $false -PasswordNeverExpires $true
            #Set-ADUser $NewAccount -ChangePasswordAtLogon $False 
            Enable-ADAccount $NewAccount
            $ArrayDataToReturn["$ADAccountName"] = "$Password"
            }
        If($ADAccountType -eq "ServiceAccount")
            {
            $ADAccountName = $AccountName.UserName
            $AccountDescription = $AccountName.Description
            $OUPath = $AccountName.OUPath
            $TargetOU = $OUPath + ",OU=" + $BaseOU + "," + $CurrentDomain.DistinguishedName
            $Password = $AccountName.PW
            $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
            New-ADUser `
            -Description $AccountDescription `
            -DisplayName $ADAccountName `
            -GivenName $ADAccountName `
            -Name $ADAccountName `
            -Path $TargetOU `
            -SamAccountName $ADAccountName `
            -CannotChangePassword $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false
            $NewAccount = Get-ADUser $ADAccountName
            Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword 
            #Set-ADAccountControl $NewAccount -CannotChangePassword $false -PasswordNeverExpires $true
            #Set-ADUser $NewAccount -ChangePasswordAtLogon $False 
            Enable-ADAccount $NewAccount
            $ArrayDataToReturn["$ADAccountName"] = "$Password"
            }
        If($ADAccountType -eq "UserAccount")
            {
            $ADAccountName = $AccountName.UserName
            $AccountDescription = $AccountName.Description
            $OUPath = $AccountName.OUPath
            $TargetOU = $OUPath + ",OU=" + $BaseOU + "," + $CurrentDomain.DistinguishedName
            $Password = $AccountName.PW
            $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
            $FirstName = $AccountName.FirstName
            $LastName = $AccountName.LastName
            $DisplayName = $FirstName + " " + $LastName
            New-ADUser `
            -Description $AccountDescription `
            -DisplayName $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -Name $DisplayName `
            -Path $TargetOU `
            -SamAccountName $ADAccountName `
            -CannotChangePassword $false `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $False 
            $NewAccount = Get-ADUser $ADAccountName
            Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
            #Set-ADAccountControl $NewAccount -CannotChangePassword $false -PasswordNeverExpires $true
            #Set-ADUser $NewAccount -ChangePasswordAtLogon $False 
            Enable-ADAccount $NewAccount
            $ArrayDataToReturn["$ADAccountName"] = "$Password"
            }
}
$ArrayDataToReturn
