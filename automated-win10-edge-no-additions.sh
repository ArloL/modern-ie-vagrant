#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

wait_for_guestcontrol() {
    while true ; do
        GuestAdditionsRunLevel=0
        echo "Waiting for ${1} to be available for guestcontrol."
        eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
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

sleep 45

VBoxManage snapshot "${VM}" list || VBoxManage snapshot "${VM}" take "Snapshot 0" --live

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium additions

# Login

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 5

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

sleep 45

# Press Win+R

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 5

#  Enter e:\vboxwindowsadditions.exe /S and press ENTER

VBoxManage controlvm "${VM}" keyboardputscancode 12 92
VBoxManage controlvm "${VM}" keyboardputscancode 2a 27 a7 aa
VBoxManage controlvm "${VM}" keyboardputscancode 2b ab
VBoxManage controlvm "${VM}" keyboardputscancode 2f af
VBoxManage controlvm "${VM}" keyboardputscancode 30 b0
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 2d ad
VBoxManage controlvm "${VM}" keyboardputscancode 11 91
VBoxManage controlvm "${VM}" keyboardputscancode 17 97
VBoxManage controlvm "${VM}" keyboardputscancode 31 b1
VBoxManage controlvm "${VM}" keyboardputscancode 20 a0
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 11 91
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 1e 9e
VBoxManage controlvm "${VM}" keyboardputscancode 20 a0
VBoxManage controlvm "${VM}" keyboardputscancode 20 a0
VBoxManage controlvm "${VM}" keyboardputscancode 17 97
VBoxManage controlvm "${VM}" keyboardputscancode 14 94
VBoxManage controlvm "${VM}" keyboardputscancode 17 97
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 31 b1
VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 39 b9
VBoxManage controlvm "${VM}" keyboardputscancode 35 b5
VBoxManage controlvm "${VM}" keyboardputscancode 2a 1f 9f aa

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 5

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

# switch to Driver Stuff

# altPress
VBoxManage controlvm "${VM}" keyboardputscancode 38
# tabPress, tabRelease
VBoxManage controlvm "${VM}" keyboardputscancode 0f 8f
# altRelease
VBoxManage controlvm "${VM}" keyboardputscancode b8

# select Yes on Driver Stuff

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait_for_guestcontrol "${VM}" 1

sleep 45

# Press Win+R

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 5

# Enter shutdown /r /t 0 and press ENTER

VBoxManage controlvm "${VM}" keyboardputscancode 1f 9f
VBoxManage controlvm "${VM}" keyboardputscancode 23 a3
VBoxManage controlvm "${VM}" keyboardputscancode 16 96
VBoxManage controlvm "${VM}" keyboardputscancode 14 94
VBoxManage controlvm "${VM}" keyboardputscancode 20 a0
VBoxManage controlvm "${VM}" keyboardputscancode 18 98
VBoxManage controlvm "${VM}" keyboardputscancode 11 91
VBoxManage controlvm "${VM}" keyboardputscancode 31 b1
VBoxManage controlvm "${VM}" keyboardputscancode 39 b9
VBoxManage controlvm "${VM}" keyboardputscancode 35 b5
VBoxManage controlvm "${VM}" keyboardputscancode 13 93
VBoxManage controlvm "${VM}" keyboardputscancode 39 b9
VBoxManage controlvm "${VM}" keyboardputscancode 35 b5
VBoxManage controlvm "${VM}" keyboardputscancode 14 94
VBoxManage controlvm "${VM}" keyboardputscancode 39 b9
VBoxManage controlvm "${VM}" keyboardputscancode 0b 8b

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait_for_guestcontrol "${VM}" 2

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium emptydrive

# Login

# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 5

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

wait_for_guestcontrol "${VM}" 3

sleep 45

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 5

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

sleep 5

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

vagrant box add --name "evosec-${box_name}" --force "${box_name}.box"
