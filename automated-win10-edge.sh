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

wait_for_virtualbox_id() {
    while true ; do
        if [ -f .vagrant/machines/default/virtualbox/id ]; then
            return 0;
        fi
        sleep 5
    done
}

export box_name=win10-edge
export boot_timeout=5

vagrant up || true

wait_for_virtualbox_id

VM=$(cat .vagrant/machines/default/virtualbox/id)

VMState=''
eval "$(VBoxManage showvminfo "${VM}" --machinereadable | grep 'VMState')"
if [ "${VMState}" != 'running' ]; then
    echo "The virtual machine ${VM} is not running."
    exit 1
fi

wait_for_guestcontrol "${VM}" 3

sleep 45

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 5

#  Enter \\vboxsrv
VBoxManage controlvm "${VM}" keyboardputscancode 2b ab
VBoxManage controlvm "${VM}" keyboardputscancode 2b ab
VBoxManage controlvm "${VM}" keyboardputscancode 2f af
VBoxManage controlvm "${VM}" keyboardputscancode 30 b0
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 2d ad
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 13 93
VBoxManage controlvm "${VM}" keyboardputscancode 2f af

sleep 5

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 5

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' stat //VBOXSRV/vagrant

{ VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision-win10-edge.bat"; } &

sleep 15

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait

vagrant provision

vagrant package --output "okeeffe-${box_name}.box" --Vagrantfile Vagrantfile-package