powershell -Command "&{ Start-Process powershell -ArgumentList '-NoExit -ExecutionPolicy Bypass -File \\VBOXSRV\vagrant\scripts\provision.ps1' -Verb RunAs }"
