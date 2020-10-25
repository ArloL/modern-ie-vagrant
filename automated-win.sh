#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

# We want the variable to expand when setting the trap
# shellcheck disable=SC2064
trap "vagrant halt ${1} --force" EXIT

if [ -f ".vagrant/machines/${1}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${1}/virtualbox/id")
else
    VM=""
fi

if [ "${VM}" != "" ] && VBoxManage snapshot "${VM}" list; then

    VBoxManage modifyvm "${VM}" \
        --recording "on" \
        --recordingfile "recordings/${1}-$(date -u +"%Y%m%dT%H%M%S").webm"

    boot_timeout=15 vagrant snapshot restore "${1}" "Snapshot 0" || true

else

    boot_timeout=15 vagrant up "${1}" || true

    VM=$(cat ".vagrant/machines/${1}/virtualbox/id")

    wait_for_guest_additions_run_level "${VM}" 2 600

    sleep 120

    vagrant snapshot save "${1}" "Snapshot 0"

fi

GuestAdditionsRunLevel=$(get_guest_additions_run_level "${VM}")

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    send_keys 14 "<enter>"

    send_keys 1 "Passw0rd!" "<enter>"

    wait_for_guest_additions_run_level "${VM}" 3 600

    sleep 120

fi

# close restart dialog
send_keys 14 "<esc>"

# Press Win+R to open the Run dialog
send_keys 1 "<winPress>" "r" "<winRelease>"

sleep 13

send_keys 1 "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat" "<enter>"

sleep 73

case ${1} in
    win7*)
        # select Yes on question whether to run script
        send_keys 14 "<left>" "<enter>"
        sleep 60
        ;;
esac

# select Yes on UAC
send_keys 14 "<left>" "<enter>"

sleep 240

wait_for_vm_to_shutdown "${VM}" 1200

vagrant up "${1}" --provision
vagrant reload "${1}" --provision
vagrant halt "${1}"

VBoxManage modifyvm "${VM}" --recording off

VBoxManage setextradata "${VM}" "GUI/Fullscreen"
VBoxManage setextradata "${VM}" "GUI/LastCloseAction"
VBoxManage setextradata "${VM}" "GUI/LastGuestSizeHint"
VBoxManage setextradata "${VM}" "GUI/LastNormalWindowPosition"
VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeDevicesMenuActions"
VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeMachineMenuActions"
VBoxManage setextradata "${VM}" "GUI/ScaleFactor"
VBoxManage setextradata "${VM}" "GUI/StatusBar/IndicatorOrder"

vagrant package "${1}" --output "${1}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${1}" --force "${1}.box"

rm -f "${1}.box"
