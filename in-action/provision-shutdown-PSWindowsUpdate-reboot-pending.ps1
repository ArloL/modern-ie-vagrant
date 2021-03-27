if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    if (PSWindowsUpdate\Get-WURebootStatus -Silent) {
        echo "Reboot required"
        shutdown /s /t 30 /f
    } else {
        echo "No reboot required"
    }
} else {
    echo "PSWindowsUpdate module does not exist"
}
