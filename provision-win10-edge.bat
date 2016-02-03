@echo on

powershell.exe -ExecutionPolicy Bypass -Command "Set-NetConnectionProfile -NetworkCategory Private"

net start schedule

call %~dp0scripts\provision-winrm.bat
