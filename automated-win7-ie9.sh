#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

box_name=win7-ie9

if [ -f "${box_name}.box" ]; then
    exit 0;
fi

if [ -f ".vagrant/machines/${box_name}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")
else
    VM=""
fi

if VBoxManage snapshot "${VM}" list; then

    boot_timeout=15 vagrant snapshot restore "${box_name}" "Snapshot 0" || true

else

    boot_timeout=15 vagrant up "${box_name}" || true

    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")

    wait_for_guest_additions_run_level "${VM}" 3

    sleep 60

    vagrant snapshot save "${box_name}" "Snapshot 0"

fi

# close restart dialog
send_keys "<esc>"

# Press Win+R to open the Run dialog
send_keys "<winPress>" r "<winRelease>"

sleep 15

send_keys "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat" "<enter>"

sleep 15

# select Yes on question whether to run script
send_keys "<left>" "<enter>"

sleep 15

# select Yes on UAC
send_keys "<left>" "<enter>"

sleep 60

wait_for_vm_to_shutdown "${VM}"

vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"

rm -f "${box_name}.box"
