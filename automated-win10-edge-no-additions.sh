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

    sleep 60

    wait_for_guest_additions_run_level "${VM}" 2

    sleep 60
    sleep 60
    sleep 60
    sleep 60
    sleep 60
    sleep 60

    vagrant snapshot save "${box_name}" "Snapshot 0"

fi

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 1 --type dvddrive --medium additions

sleep 60

# Press Win+R
send_keys "<winPress>" r "<winRelease>"

sleep 15

# Enter e:\vboxwindowsadditions /S and press ENTER

send_keys e ":" \\ v b o x w i n d o w s a d d i t i o n s " " / S "<enter>"

sleep 15

# select Yes on UAC

send_keys "<left>" "<enter>"

sleep 15

wait_for_guest_additions_run_level "${VM}" 1

sleep 60

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 1 --type dvddrive --medium emptydrive

# Press Win+R
send_keys "<winPress>" r "<winRelease>"

sleep 15

# Enter shutdown /r /t 0 and press ENTER

send_keys s h u t d o w n " " / r " " / t " " 0 "<enter>"

wait_for_guest_additions_run_level "${VM}" 3

sleep 60

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.
send_keys "<winPress>" r "<winRelease>"

sleep 15

send_keys \\ \\ v b o x s r v "<enter>"

sleep 30

# Make sure the folder is available so we can run our script from there

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' stat //VBOXSRV/vagrant

{ VBoxManage guestcontrol "${VM}" --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision.bat"; } &

provisionPID=$!

sleep 15

# select Yes on UAC

send_keys "<left>" "<enter>"

wait ${provisionPID} || true

wait_for_guest_additions_run_level "${VM}" 0

unset boot_timeout
vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"

rm -f "${box_name}.box"
