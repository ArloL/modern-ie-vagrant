@echo off

rmdir "C:\tmp" /S /Q

PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\provision-network-private.ps1
PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\provision-psremoting.ps1
