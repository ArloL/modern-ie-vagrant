if ($PSVersionTable.PSVersion.Major -ge 3) {
    echo "PowerShell is GTE to 3"
    return
}

if (Get-HotFix -Id KB3191566) {
    echo "KB3191566 is already installed"
    return
}

$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

. $scriptDir\Unzip.ps1

$path = Join-Path $env:TEMP "Win7-KB3191566-x86"

md $path -Force

(New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?linkid=839522", "$path\Win7-KB3191566-x86.zip")

Unzip "$path\Win7-KB3191566-x86.zip" $path

While (!(Get-HotFix -Id KB3191566)) {
    wusa.exe "$path/Win7-KB3191566-x86.msu" /quiet /norestart | Out-Null
}

Remove-Item $path -Recurse -Force
