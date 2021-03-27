if (!(Test-Path $PROFILE)) {
    New-Item -Type File -Force $PROFILE
}
