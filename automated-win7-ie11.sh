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

export box_name=win7-ie11
export boot_timeout=5

vagrant up || true

VM=$(cat .vagrant/machines/default/virtualbox/id)

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

# escPress, escRelease
VBoxManage controlvm "${VM}" keyboardputscancode 01 81

{ VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision-${box_name}.bat"; } &

sleep 15

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait

vagrant provision

vagrant package --output "${box_name}.box" --Vagrantfile Vagrantfile-package
