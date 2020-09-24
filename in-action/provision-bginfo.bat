@echo off
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v bginfo /f
reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "0 99 177" /f
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f
%SystemRoot%\System32\RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
exit /b 0
