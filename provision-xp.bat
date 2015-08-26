@echo on

%~dp0scripts\NetFx20SP1_x86.exe /q /norestart
%~dp0scripts\WindowsXP-KB968930-x86-ENG.exe /quiet /passive /norestart

call %~dp0scripts\provision-fake-mklink.bat

reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /t REG_DWORD /v forceguest /d 0 /f

call %~dp0scripts\provision-winrm.bat
