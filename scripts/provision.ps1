reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "IEUser" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Passw0rd!" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "1" /f

\\VBOXSRV\vagrant\scripts\vagrant-onstart.ps1

copy \\VBOXSRV\vagrant\scripts\vagrant-onstart.ps1 C:\Users\IEUser\vagrant-onstart.ps1
copy \\VBOXSRV\vagrant\scripts\vagrant-onstart.cmd C:\Users\IEUser\vagrant-onstart.cmd

net start schedule

schtasks /Create /SC ONLOGON /TN "vagrant-onstart" /TR "C:\Users\IEUser\vagrant-onstart.cmd" /RL HIGHEST /DELAY 0000:30 /F

start slmgr /rearm

\\VBOXSRV\vagrant\scripts\provision-wmf51.ps1

Get-ChildItem "\\VBOXSRV\vagrant\scripts\VBoxGuestAdditions\cert" -Filter *.cer |
Foreach-Object {
    certutil -addstore -f "TrustedPublisher" $_.FullName
}

\\VBOXSRV\vagrant\scripts\VBoxGuestAdditions\VBoxWindowsAdditions.exe /S

shutdown /s /t 30 /f