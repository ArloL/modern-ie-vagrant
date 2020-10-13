#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

export box_name=win10-edge
export boot_timeout=5

if [ -f "${box_name}.box" ]; then
    exit 0;
fi

if [ -f ".vagrant/machines/${box_name}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")
else
    VM=""
fi

if VBoxManage snapshot "${VM}" list; then

    vagrant snapshot restore "${box_name}" "Snapshot 0" || true

else

    vagrant up "${box_name}" || true

    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")

    wait_for_guest_additions_run_level "${VM}" 2

    sleep 60

    vagrant snapshot save "${box_name}" "Snapshot 0"

fi

GuestAdditionsRunLevel=$(get_guest_additions_run_level "${VM}")

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    # Login

    send_keys "<enter>"

    sleep 15

    # Enter Passw0rd!
    send_keys P a s s w 0 r d "!" "<enter>"

    wait_for_guest_additions_run_level "${VM}" 3

    sleep 60

fi

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.

send_keys "<winPress>" r "<winRelease>"

sleep 15

send_keys "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat" "<enter>"

sleep 15

# select Yes on UAC
send_keys "<left>" "<enter>"

sleep 60

wait_for_vm_to_shutdown "${VM}"

unset boot_timeout
vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"

rm -f "${box_name}.box"
