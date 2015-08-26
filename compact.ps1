function Unzip($zip, $destination) {
    $shell = New-Object -COMObject "Shell.Application"
    $zip = $shell.NameSpace($zip)
    $destination = $shell.NameSpace($destination)
    foreach($item in $zip.items()) {
        $target = $destination.ParseName($item.Path).Path
        if (!(Test-Path $target)) {
            $destination.CopyHere($item)
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

net stop wuauserv
Remove-Item C:\Windows\SoftwareDistribution\Download -Recurse -Force
mkdir C:\Windows\SoftwareDistribution\Download
net start wuauserv

& C:\Windows\Temp\ultradefrag-portable-6.1.0.$architecture\udefrag.exe --optimize --repeat C:

reg add HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
& C:\Windows\Temp\sdelete.exe -q -z C:
