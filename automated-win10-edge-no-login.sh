#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

get_guest_additions_run_level() {
    GuestAdditionsRunLevel=0
    eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
    echo ${GuestAdditionsRunLevel}
}

wait_for_guestcontrol() {
    while true ; do
        echo "Waiting for ${1} to be available for guestcontrol."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level "${1}")
        if [ "${GuestAdditionsRunLevel}" -eq "${2}" ]; then
            return 0;
        fi
        sleep 5
    done
}

export box_name=win10-edge
export boot_timeout=5

if [ -f "${box_name}.box" ]; then
    exit 0;
fi

vagrant up || true

VM=$(cat .vagrant/machines/default/virtualbox/id)

sleep 60

VBoxManage snapshot "${VM}" list || VBoxManage snapshot "${VM}" take "Snapshot 0" --live

# Login

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# Enter Passw0rd!
VBoxManage controlvm "${VM}" keyboardputscancode 2a 19 99 aa
VBoxManage controlvm "${VM}" keyboardputscancode 1e 9e
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 11 91
VBoxManage controlvm "${VM}" keyboardputscancode 0b 8b
VBoxManage controlvm "${VM}" keyboardputscancode 13 93
VBoxManage controlvm "${VM}" keyboardputscancode 20 a0
VBoxManage controlvm "${VM}" keyboardputscancode 2a 02 82 aa

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 60

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 15

#  Enter \\vboxsrv and press ENTER

VBoxManage controlvm "${VM}" keyboardputscancode 2b ab
VBoxManage controlvm "${VM}" keyboardputscancode 2b ab
VBoxManage controlvm "${VM}" keyboardputscancode 2f af
VBoxManage controlvm "${VM}" keyboardputscancode 30 b0
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 2d ad
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 13 93
VBoxManage controlvm "${VM}" keyboardputscancode 2f af

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 30

# Make sure the folder is available so we can run our script from there

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' stat //VBOXSRV/vagrant

{ VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision-${box_name}.bat"; } &

provisionPID=$!

sleep 15

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait ${provisionPID} || true

wait_for_guestcontrol "${VM}" 0

vagrant package --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"