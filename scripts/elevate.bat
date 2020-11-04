powershell -Command "&{ Start-Process powershell -ArgumentList '-NoExit -ExecutionPolicy Bypass -File %1%2.ps1' -Verb RunAs -WorkingDirectory '%1' }"
