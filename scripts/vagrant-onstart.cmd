@echo off

rmdir "C:\tmp" /S /Q

PowerShell -ExecutionPolicy Bypass -File C:\Users\IEUser\provision-network-private.ps1
