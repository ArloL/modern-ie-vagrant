function Unzip($zip, $destination, $overwrite = $false) {
    $shell = New-Object -COMObject "Shell.Application"
    $zip = $shell.NameSpace($zip)
    foreach($item in $zip.items()) {
        $target = "$($destination)\$($item.Path)"
        if ($overwrite) {
            Remove-Item $target -Recurse -Force
        }
        if (!(Test-Path $target)) {
            $shell.NameSpace($destination).CopyHere($item)
        }
    }
}

$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

$architecture = "amd64"
if ([IntPtr]::size -eq 4) {
    $architecture = "i386"
}

Unzip "$($scriptDir)\scripts\ultradefrag-portable-6.1.0.bin.$($architecture).zip" "C:\Windows\Temp"
Unzip "$($scriptDir)\scripts\SDelete.zip" "C:\Windows\Temp"

& C:\Windows\Temp\ultradefrag-portable-6.1.0.$architecture\udefrag.exe --optimize --repeat C:

reg add HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
& C:\Windows\Temp\sdelete.exe -q -z C:
