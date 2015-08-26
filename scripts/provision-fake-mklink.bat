@echo on

expand %~dp0symlink-1.06-x86.cab -f:* C:\Windows\system32
copy /Y %~dp0mklink.cmd C:\Windows\system32
copy /Y %~dp0Symlink.ps1 C:\Windows\system32

schtasks /create /tn "senable install" /tr "senable install" /sc onstart /ru ""
