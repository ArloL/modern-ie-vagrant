function Unzip($zip, $destination, $overwrite = $false) {
    $shell = New-Object -COMObject "Shell.Application"
    $zip = $shell.NameSpace($zip)
    foreach($item in $zip.items()) {
        $target = "$($destination)\$($item.Path | Split-Path -Leaf)"
        if ((Test-Path $target) -And $overwrite) {
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

Unzip "$($scriptDir)\scripts\ultradefrag-portable-7.0.1.bin.$($architecture).zip" "C:\Windows\Temp"
& C:\Windows\Temp\ultradefrag-portable-7.0.1.$architecture\udefrag.exe --quick-optimize C:
Remove-Item C:\Windows\Temp\ultradefrag-portable-7.0.1.$architecture -Recurse -Force

Unzip "$($scriptDir)\scripts\SDelete.zip" "C:\Windows\Temp"
reg add HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
& C:\Windows\Temp\sdelete.exe -q -z C:
reg delete HKCU\Software\Sysinternals\SDelete /f
Remove-Item C:\Windows\Temp\sdelete.exe
Remove-Item C:\Windows\Temp\Eula.txt
