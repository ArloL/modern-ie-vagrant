@echo on

powershell.exe -ExecutionPolicy Bypass -File %~dp0scripts\provision-network-private.ps1

call %~dp0scripts\provision-winrm.bat

for %%i in (%~dp0scripts\vbox_*.cer) do certutil -addstore -f "TrustedPublisher" %%i
