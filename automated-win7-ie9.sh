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

export box_name=win7-ie9
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

    wait_for_guestcontrol "${VM}" 3

    sleep 60

    vagrant snapshot save "${box_name}" "Snapshot 0"

fi

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

{ VBoxManage guestcontrol "${VM}" --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision.bat"; } &

provisionPID=$!

sleep 15

# switch to UAC

# altPress
VBoxManage controlvm "${VM}" keyboardputscancode 38
# tabPress, tabRelease
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
# altRelease
VBoxManage controlvm "${VM}" keyboardputscancode b8

sleep 5

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait ${provisionPID} || true

wait_for_guestcontrol "${VM}" 0

unset boot_timeout
vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"
