#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

export box_name=win7-ie11
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

    wait_for_guest_additions_run_level "${VM}" 3

    sleep 60

    vagrant snapshot save "${box_name}" "Snapshot 0"

fi

# close restart dialog
send_keys "${VM}" "<esc>"

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.
send_keys "${VM}" "<winPress>" r "<winRelease>"

sleep 15

send_keys "${VM}" \\ \\ v b o x s r v "<enter>"

sleep 30

# Make sure the folder is available so we can run our script from there

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' stat //VBOXSRV/vagrant

{ VBoxManage guestcontrol "${VM}" --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision.bat"; } &

provisionPID=$!

sleep 15

# switch to UAC

send_keys "${VM}" "<altPress>" "<tab>" "<altRelease>"

sleep 5

# select Yes on UAC

send_keys "${VM}" "<left>" "<enter>"

wait ${provisionPID} || true

wait_for_guest_additions_run_level "${VM}" 0

unset boot_timeout
vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"

rm -f "${box_name}.box"
