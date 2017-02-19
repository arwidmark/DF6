$BDERecoveryFile = Get-Item -Path "c:\$env:COMPUTERNAME-{*.txt"
if($BDERecoveryFile.count -eq "1"){
    Write-Host "BDE Recovery Paswword file exist, removing"
    Remove-Item $BDERecoveryFile.FullName
    }
