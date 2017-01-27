$architecture = "64"
if ([IntPtr]::size -eq 4) {
    $architecture = ""
}

reg add HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
& \\VBOXSVR\vagrant\scripts\ultradefrag$architecture\udefrag.exe --quick-optimize C:
& \\VBOXSVR\vagrant\scripts\SDelete\sdelete$architecture.exe -q -z C:
reg delete HKCU\Software\Sysinternals\SDelete /f
