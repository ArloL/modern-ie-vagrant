#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

wait_for_guestcontrol() {
    GuestAdditionsRunLevel=0
    while true ; do
        echo "Waiting for ${1} to be available for guestcontrol."
        eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
        if [ "${GuestAdditionsRunLevel}" -eq "${2}" ]; then
            return 0;
        fi
        sleep 5
    done
}

export box_name=win7-ie8
export boot_timeout=5

vagrant up || true

VM=$(cat .vagrant/machines/default/virtualbox/id)

wait_for_guestcontrol "${VM}" 3

sleep 60

VBoxManage snapshot "${VM}" list || VBoxManage snapshot "${VM}" take "Snapshot 0" --live

# close restart dialog

# escPress, escRelease
VBoxManage controlvm "${VM}" keyboardputscancode 01 81

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

# altPress
VBoxManage controlvm "${VM}" keyboardputscancode 38
# tabPress, tabRelease
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
# altRelease
VBoxManage controlvm "${VM}" keyboardputscancode b8

sleep 5

# select Yes on UAC

# tabPress, tabRelease
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait ${provisionPID}

vagrant provision

vagrant package --output "${box_name}.box" --Vagrantfile Vagrantfile-package