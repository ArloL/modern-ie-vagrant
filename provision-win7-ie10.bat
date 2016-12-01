@echo on

call %~dp0scripts\provision-winrm.bat

for %%i in (%~dp0scripts\vbox_*.cer) do certutil -addstore -f "TrustedPublisher" %%i
