@echo on

%~dp0scripts\NetFx20SP1_x86.exe /q /norestart
if %ERRORLEVEL% EQU 9009 echo "Prerequisites missing "&& pause && exit /b

%~dp0scripts\WindowsXP-KB968930-x86-ENG.exe /quiet /passive /norestart
if %ERRORLEVEL% EQU 9009 echo "Prerequisites missing "&& pause && exit /b

call %~dp0scripts\provision-fake-mklink.bat

reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /t REG_DWORD /v forceguest /d 0 /f

call %~dp0scripts\provision-winrm.bat
