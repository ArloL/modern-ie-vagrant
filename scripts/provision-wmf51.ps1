if ($PSVersionTable.PSVersion.Major -ge 3) {
    echo "PowerShell is GTE to 3"
    return
}

$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

$path = Join-Path $scriptDir "Win7-KB3191566-x86"

While (!(Get-HotFix -Id KB3191566)) {
    wusa.exe "$path/Win7-KB3191566-x86.msu" /quiet /norestart | Out-Null
}
