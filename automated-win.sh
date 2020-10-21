#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

if [ -f ".vagrant/machines/${1}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${1}/virtualbox/id")
else
    VM=""
fi

if VBoxManage snapshot "${VM}" list; then

    boot_timeout=15 vagrant snapshot restore "${1}" "Snapshot 0" || true

else

    boot_timeout=15 vagrant up "${1}" || true

    VM=$(cat ".vagrant/machines/${1}/virtualbox/id")

    wait_for_guest_additions_run_level "${VM}" 2

    sleep 120

    vagrant snapshot save "${1}" "Snapshot 0"

fi

GuestAdditionsRunLevel=$(get_guest_additions_run_level "${VM}")

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    send_keys "<enter>"

    sleep 15

    send_keys "Passw0rd!" "<enter>"

    wait_for_guest_additions_run_level "${VM}" 3

    sleep 60

fi

# close restart dialog
send_keys "<esc>"

# Press Win+R to open the Run dialog
send_keys "<winPress>" r "<winRelease>"

sleep 15

send_keys "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat" "<enter>"

sleep 15

case "$1" in
    # select Yes on question whether to run script
    win7*) send_keys "<left>" "<enter>"; sleep 15;;
esac

# select Yes on UAC
send_keys "<left>" "<enter>"

sleep 120

wait_for_vm_to_shutdown "${VM}"

vagrant up "${1}" --provision
vagrant reload "${1}" --provision
vagrant halt "${1}"

vagrant package "${1}" --output "${1}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${1}" --force "${1}.box"

rm -f "${1}.box"
