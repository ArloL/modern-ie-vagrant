reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f

& "C:\Program Files\Oracle\VirtualBox Guest Additions\uninst.exe" /S

shutdown /s /t 30 /f
