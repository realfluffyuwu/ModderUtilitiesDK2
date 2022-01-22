$Version = 0.4
$FPSName = split-Path $PSCommandPath -Leaf
$FPSName = $FPSName.Substring(0,(($FPSName.Length) - 4))
$UtilVersionList = Invoke-RestMethod "https://raw.githubusercontent.com/MrFlufficans/DK2ModderUtilities/master/UtilVersion"
$VersionLine = ($UtilVersionList).split([Environment]::NewLine) | Select-String -Pattern "$FPSName" -SimpleMatch
$VersionLine = $VersionLine.ToString()
$VersionMaster = $VersionLine.SubString(($VersionLine.Length) -3)
$NewVersion = Invoke-RestMethod "https://raw.githubusercontent.com/MrFlufficans/DK2ModderUtilities/master/$FPSName.ps1"

$FluffyUtils = "
   ______     ______       __  ____  _ __  
  / __/ /_ __/ _/ _/_ __  / / / / /_(_) /__
 / _// / // / _/ _/ // / / /_/ / __/ / (_-<
/_/ /_/\_,_/_//_/ \_, /  \____/\__/_/_/___/
                 /___/                     
"

Write-Host $FluffyUtils 
Write-Host "   You Are Running $FPSName v$Version"
Write-Host "    Hosted On Github.com/MrFlufficans"
if ($VersionMaster -gt $Version) {
    Write-Host "`n  There is a New Version Available v$VersionMaster`n        Would you Like to Update?"
    $ConfirmUpdate = Read-Host "`t`t"
    $ConfirmUpdate = ($ConfirmUpdate.ToLower()).ToString()
    If ($ConfirmUpdate -match '^y(es)?$') {
        $Update = 1
    } else {
        $Update = 0    
    }
} else {$Update = 0}

Start-Sleep 1

If ($Update) {
    Write-Host "`nFetching Update"
    Start-Sleep 1
    If (Test-Path -Path ".\$FPSName.ps1" -PathType Leaf) {Clear-Content ".\$FPSName.ps1"}
    $NewVersion >> "$FPSName.ps1"
    Write-Host "Script Updated"
    Start-Sleep 1
    Write-Host "Relaunching in 3"
    Start-Sleep 1
    Write-Host "Relaunching in 2"
    Start-Sleep 1
    Write-Host "Relaunching in 1"
    Start-Sleep 1
    Start-Process powershell ".\$FPSName.ps1"
    Exit
} else {}


#Everything Above is just the Auto Update
#Actual Script Below Here

if (Test-Path -Path ".\AuthorSig" -PathType Leaf) {
    $AuthorSig = (Get-Content ".\AuthorSig*").split([Environment]::NewLine)
    if (($AuthorSig | Select-Object -Index 0) -match "https://github.com/*") {
        $AuthorName = ((($AuthorSig | Select-Object -Index 0)).split("/")) | Select-Object -Index 3
        $ModName = ((($AuthorSig | Select-Object -Index 0)).split("/")) | Select-Object -Index 4
        $GithubBranch = ""
        $GithubURL = ($AuthorSig | Select-Object -Index 0)
        
        $ErrorActionPreference = "silentlycontinue"
        $MasterStatus = (Invoke-WebRequest -uri "$GithubURL/archive/refs/heads/main.zip" -UseBasicParsing -DisableKeepAlive).StatusCode
        $ErrorActionPreference = "continue"
        
        if ($null -eq $MasterStatus) {$GithubBranch = "/archive/refs/heads/master.zip"} else {$GithubBranch = "/archive/refs/heads/main.zip"}
        
        $GithubURL = "$GithubURL$GithubBranch"
        
    } else {
        
        Write-Host "`n     Found Author Signature File"
        $AuthorName = $AuthorSig | Select-Object -Index 0
        $ModName = $AuthorSig | Select-Object -Index 1
        $GithubBranch = $AuthorSig | Select-Object -Index 2
        
        Write-Host "   Downloading $ModName`n`t  by $AuthorName"
    }
} else {
    
    Write-Host "`nI couldn't Find the Author Signature File"
    $InputManually = Read-Host "  Would you Like to Input Manually?"
    $InputManually = ($InputManually.ToLower()).ToString()
    
    if ($InputManually -match '^y(es)?$') {
    $AuthorName = Read-Host "`nAuthor's Name?"
        $ModName = Read-Host "Mod's Name?"
        $GithubBranch = Read-Host "The Mods Branch on Github?"
        Write-Host "`n   Downloading $ModName`n`tby $AuthorName"
        Start-Sleep 1
    } else {
        Write-Host "`n Please Create an Author Signature File"
        Start-Sleep 4
        exit
    }
}
if ($null -eq $GithubURL) {$GithubURL = "https://github.com/$AuthorName/$ModName/archive/refs/heads/$GithubBranch.zip"}
Write-Host "`n   Downloading $ModName`n`tby $AuthorName"
Invoke-RestMethod -uri $GithubURL -OutFile ".\$ModName.zip"
Expand-Archive -Path ".\$ModName.zip" -Destination ".\$ModName" -Force

Start-Sleep 3
Copy-Item -Path ".\$ModName\$ModName*" -Destination ".\Temp$ModName" -Force -Recurse
Remove-Item -Path ".\$ModName.zip" -Recurse
Remove-Item -Path ".\$ModName" -Recurse
Start-Sleep 2
Rename-Item -Path ".\Temp$ModName" -NewName "$ModName"
Write-Host "`n    Mod Downloaded and Extracted!"
Start-Sleep 3