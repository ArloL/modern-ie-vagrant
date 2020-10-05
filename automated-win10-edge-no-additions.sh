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

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 15

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

sleep 15

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

sleep 15

wait_for_guest_additions_run_level "${VM}" 1

sleep 60

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 1 --type dvddrive --medium emptydrive

# Press Win+R

# leftWindowPress, rPress, rRelease, leftWindowRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 5b 13 93 e0 db

sleep 15

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

wait_for_guest_additions_run_level "${VM}" 3

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

{ VBoxManage guestcontrol "${VM}" --username IEUser --password 'Passw0rd!' run --exe "//VBOXSRV/vagrant/elevate-provision.bat"; } &

provisionPID=$!

sleep 15

# select Yes on UAC

# leftPress, leftRelease
VBoxManage controlvm "${VM}" keyboardputscancode e0 4b e0 cb
# enterPress, enterRelease
VBoxManage controlvm "${VM}" keyboardputscancode 1c 9c

wait ${provisionPID} || true

wait_for_guest_additions_run_level "${VM}" 0

unset boot_timeout
vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

vagrant package "${box_name}" --output "${box_name}.box" --Vagrantfile Vagrantfile-package

vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"

rm -f "${box_name}.box"
