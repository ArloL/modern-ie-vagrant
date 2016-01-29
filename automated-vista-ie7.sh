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

export box_name=vista-ie7
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

sleep 60

# setup

# upPress, upRelease
VBoxManage controlvm "${VM}" keyboardputscancode 48 c8
# upPress, upRelease
VBoxManage controlvm "${VM}" keyboardputscancode 48 c8
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# escPress, escRelease
VBoxManage controlvm "${VM}" keyboardputscancode 01 80

sleep 5

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' start --exe "//VBOXSRV/vagrant/elevate-provision-vista-ie7.bat"

sleep 5

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 30

vagrant reload --provision

vagrant package --output "okeeffe-${box_name}.box" --Vagrantfile Vagrantfile-package
