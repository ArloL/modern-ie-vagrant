powershell -Command "&{ Start-Process powershell -ArgumentList '-NoExit -ExecutionPolicy Bypass -File \\VBOXSRV\vagrant\scripts\%1.ps1' -Verb RunAs }"
