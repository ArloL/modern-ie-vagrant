$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
if (Get-Command refreshenv -errorAction SilentlyContinue) {
    refreshenv
}
Get-Item env:* | Format-Table -AutoSize -Wrap
if ($PSVersionTable.PSVersion.Major -lt 3) {
    throw 'Wrong PowerShell version'
}
