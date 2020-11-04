$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

cd $scriptDir

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "IEUser" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Passw0rd!" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "1" /f

copy .\vagrant-onstart.ps1 C:\Users\IEUser\vagrant-onstart.ps1
copy .\vagrant-onstart.cmd C:\Users\IEUser\vagrant-onstart.cmd

net start schedule

schtasks /Create /TN "vagrant-onstart" /XML ".\vagrant-onstart.xml" /F

.\provision-wmf51.ps1

Get-ChildItem ".\VBoxGuestAdditions\cert" -Filter *.cer |
Foreach-Object {
    certutil -addstore -f "TrustedPublisher" $_.FullName
}

.\VBoxGuestAdditions\VBoxWindowsAdditions.exe /S | Out-Null

start slmgr /rearm

shutdown /s /t 30 /f
