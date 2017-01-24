@echo on

copy %~dp0scripts\provision-network-private.ps1 C:\Users\IEUser\provision-network-private.ps1

copy %~dp0scripts\vagrant-onstart.cmd C:\Users\IEUser\vagrant-onstart.cmd

PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\provision-network-private.ps1

net start schedule

call %~dp0scripts\provision-winrm.bat

for %%i in (%~dp0scripts\VBoxGuestAdditions\cert\vbox-*.cer) do certutil -addstore -f "TrustedPublisher" %%i

PowerShell -ExecutionPolicy Bypass -File \\VBOXSRV\vagrant\hello.ps1

schtasks /Create /SC ONSTART /TN "vagrant-onstart" /TR "C:\Users\IEUser\vagrant-onstart.cmd" /RL HIGHEST /DELAY 0000:20 /F

start slmgr /rearm

\\VBOXSRV\vagrant\scripts\VBoxGuestAdditions\VBoxWindowsAdditions.exe /S

shutdown -s -t 0
