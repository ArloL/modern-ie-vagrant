@echo on

powershell.exe -ExecutionPolicy Bypass -Command "Set-NetConnectionProfile -NetworkCategory Private"

net start schedule

call %~dp0scripts\provision-winrm.bat

for %%i in (%~dp0scripts\VBoxGuestAdditions\cert\vbox-*.cer) do certutil -addstore -f "TrustedPublisher" %%i
