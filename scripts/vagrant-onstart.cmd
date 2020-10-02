@echo off

rmdir "C:\tmp" /S /Q

PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\vagrant-onstart.ps1
