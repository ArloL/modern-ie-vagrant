$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

. $scriptDir\Unzip.ps1

$path = Join-Path $env:TEMP "Win7-KB3191566-x86"

md $path -Force

(New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?linkid=839522", "$path\Win7-KB3191566-x86.zip")

Unzip "$path\Win7-KB3191566-x86.zip" $path $true

wusa.exe "$path/Win7-KB3191566-x86.msu" /quiet /norestart | Out-Null
