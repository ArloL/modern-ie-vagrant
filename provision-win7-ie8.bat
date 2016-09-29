@echo on

powershell.exe -ExecutionPolicy Bypass -File %~dp0scripts\provision-network-private.ps1

call %~dp0scripts\provision-winrm.bat

set WINRM_EXEC=call %SYSTEMROOT%\system32\winrm
%WINRM_EXEC% set winrm/config/winrs @{MaxShellsPerUser="999999999"}
%WINRM_EXEC% set winrm/config/winrs @{MaxConcurrentUsers="100"}
%WINRM_EXEC% set winrm/config/winrs @{MaxProcessesPerShell="999999999"}
%WINRM_EXEC% set winrm/config/service @{MaxConcurrentOperationsPerUser="999999999"}
