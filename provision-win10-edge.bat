@echo on

powershell.exe -ExecutionPolicy Bypass -Command "Set-NetConnectionProfile -NetworkCategory Private"

call %~dp0scripts\provision-winrm.bat
