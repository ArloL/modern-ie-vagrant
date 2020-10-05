#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

export box_name=win10-preview-edge
export boot_timeout=5

if [ -f "${box_name}.box" ]; then
    exit 0;
fi

vagrant up "${box_name}" || true

VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")

wait_for_guest_additions_run_level "${VM}" 2

sleep 60

VBoxManage snapshot "${VM}" list || VBoxManage snapshot "${VM}" take "Snapshot 0" --live

GuestAdditionsRunLevel=$(get_guest_additions_run_level "${VM}")

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    # Login

    send_keys "${VM}" "<enter>"

    sleep 15

    # Enter Passw0rd!
    send_keys "${VM}" P a s s w 0 r d "!" "<enter>"

    wait_for_guest_additions_run_level "${VM}" 3

    sleep 60

fi

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.

send_keys "${VM}" "<winPress>" r "<winRelease>"

sleep 15

#  Enter \\vboxsrv and press ENTER

send_keys "${VM}" \\ \\ v b o x s r v "<enter>"

sleep 30

# Make sure the folder is available so we can run our script from there

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' stat //VBOXSRV/vagrant

{ VBoxManage guestcontrol "${VM}" --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision.bat"; } &

provisionPID=$!

sleep 15

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
