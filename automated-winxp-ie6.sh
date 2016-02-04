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

export box_name=winxp-ie6
export boot_timeout=5

vagrant up || true

VM=$(cat .vagrant/machines/default/virtualbox/id)

wait_for_guestcontrol "${VM}" 2

sleep 10

VBoxManage snapshot "${VM}" list || VBoxManage snapshot "${VM}" take "Snapshot 0" --live

# altPress, tabPress, tabRelease, altRelease
VBoxManage controlvm "${VM}" keyboardputscancode 38 0f 8f b8
# tabPress, tabRelease
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait_for_guestcontrol "${VM}" 3

sleep 60

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/provision-${box_name}.bat"

# remove wga

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password 'Passw0rd!' start --exe "//VBOXSRV/vagrant/scripts/removewga.exe"

sleep 5

# confirm removal of wga

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 5

# confirm restart for removal of wga

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

# wait for restart after executing removewga

wait_for_guestcontrol "${VM}" 0

wait_for_guestcontrol "${VM}" 2

sleep 60

# confirm removewga

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait_for_guestcontrol "${VM}" 3

vagrant provision

vagrant package --output "${box_name}.box" --Vagrantfile Vagrantfile-package
