@echo on

expand %~dp0symlink-1.06-x86.cab -f:* C:\Windows\system32
copy /Y %~dp0mklink.cmd C:\Windows\system32
copy /Y %~dp0Symlink.ps1 C:\Windows\system32
copy /Y %~dp0autostart-senable.bat "C:\Documents and Settings\All Users\Start Menu\Programs\Startup"
