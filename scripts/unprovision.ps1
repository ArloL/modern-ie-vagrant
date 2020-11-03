reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f

$target="C:\Program Files\Oracle\VirtualBox Guest Additions\uninst.exe"
if (Test-Path $target) {
    & $target /S
}

shutdown /s /t 30 /f
