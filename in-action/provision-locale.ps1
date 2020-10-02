$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

control "intl.cpl,,/f:`"$scriptDir\locale-de-DE.xml`""
