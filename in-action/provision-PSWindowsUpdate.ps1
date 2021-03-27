if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw 'Wrong PowerShell version'
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force -AllowClobber
Get-Package -Name PSWindowsUpdate
$updates = PSWindowsUpdate\Get-WindowsUpdate -AcceptAll -IgnoreUserInput -Confirm:$false -MicrosoftUpdate -Verbose -Install -IgnoreReboot
if ($updates.count -gt 0) {
    $state = "updates"
} elseif (PSWindowsUpdate\Get-WURebootStatus -Silent) {
    $state = "reboot"
} else {
    $state = "done"
}
$state | Out-File -FilePath "C:\vagrant\update-state-${env:BOX_NAME}.log" -Encoding ascii -NoNewline
