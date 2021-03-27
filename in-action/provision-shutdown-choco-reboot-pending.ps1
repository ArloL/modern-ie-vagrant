if (Get-Command choco -errorAction SilentlyContinue) {
    choco install --exit-when-reboot-detected powershell
    if ($LASTEXITCODE -eq 350 -or $LASTEXITCODE -eq 1604) {
        echo "Reboot required"
        shutdown /s /t 30 /f
    } else {
        echo "No reboot required"
    }
} else {
    echo "choco command does not exist"
}
