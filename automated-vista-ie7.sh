#!/bin/sh

echo Sadly there is an issue with the 20150916 build. There are no guest additions installed. To make it easier for now this script does not work.
exit 1

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

export box_name=vista-ie7
export boot_timeout=5

vagrant up || true

VM=$(cat .vagrant/machines/default/virtualbox/id)

wait_for_guestcontrol "${VM}" 3

sleep 60

VBoxManage snapshot "${VM}" take "Snapshot $(date -u +"%Y-%m-%dT%H:%M:%SZ")" --live

# select home network

# upPress, upRelease
VBoxManage controlvm "${VM}" keyboardputscancode 48 c8
# upPress, upRelease
VBoxManage controlvm "${VM}" keyboardputscancode 48 c8
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# close dialog

# escPress, escRelease
VBoxManage controlvm "${VM}" keyboardputscancode 01 81

{ VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision-${box_name}.bat"; } &

sleep 15

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode 4b cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait

vagrant provision

vagrant package --output "${box_name}.box" --Vagrantfile Vagrantfile-package
