@echo on

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "IEUser" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Passw0rd!" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "1" /f

copy %~dp0scripts\vagrant-onstart.ps1 C:\Users\IEUser\vagrant-onstart.ps1
copy %~dp0scripts\vagrant-onstart.cmd C:\Users\IEUser\vagrant-onstart.cmd

PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\vagrant-onstart.ps1

net start schedule

call %~dp0scripts\provision-winrm.bat

for %%i in (%~dp0scripts\VBoxGuestAdditions\cert\vbox-*.cer) do certutil -addstore -f "TrustedPublisher" %%i

schtasks /Create /SC ONSTART /TN "vagrant-onstart" /TR "C:\Users\IEUser\vagrant-onstart.cmd" /RL HIGHEST /DELAY 0000:20 /F

start slmgr /rearm

sc config "winrm" start= demand

PowerShell -ExecutionPolicy Bypass -File \\VBOXSRV\vagrant\scripts\provision-wmf51.ps1

\\VBOXSRV\vagrant\scripts\VBoxGuestAdditions\VBoxWindowsAdditions.exe /S

shutdown /s /t 30 /f

sleep 30
