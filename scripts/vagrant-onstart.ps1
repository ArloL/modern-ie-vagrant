$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()
$connections | % {$_.GetNetwork().SetCategory(1)}

Enable-PSRemoting -Force

Set-Item wsman:\localhost\Shell\MaxMemoryPerShellMB 1024
Set-Item wsman:\localhost\MaxTimeoutms 1800000
Set-Item wsman:\localhost\Client\Auth\Basic true
Set-Item wsman:\localhost\Service\AllowUnencrypted true
Set-Item wsman:\localhost\Service\Auth\Basic true

Set-Service "winrm" -startupType manual
