#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

box_name=win10-edge

# We want the variable to expand when setting the trap
# shellcheck disable=SC2064
trap "vagrant halt ${box_name} --force" EXIT

if [ -f ".vagrant/machines/${box_name}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")
else
    VM=""
fi

if [ "${VM}" != "" ] && VBoxManage snapshot "${VM}" list; then

    VBoxManage modifyvm "${VM}" \
        --recording "on" \
        --recordingfile "recordings/${box_name}-$(date -u +"%Y%m%dT%H%M%S").webm"

    boot_timeout=15 vagrant snapshot restore "${box_name}" "Snapshot 0" || true

else

    boot_timeout=15 vagrant up "${box_name}" || true

    VM=$(cat ".vagrant/machines/${box_name}/virtualbox/id")

    sleep 120

    wait_for_guest_additions_run_level "${VM}" 2 600

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
send_keys 4 "<winPress>" r "<winRelease>"

sleep 10

send_keys 14 "e:\\vboxwindowsadditions /S" "<enter>"

sleep 60

# select Yes on UAC
send_keys 14 "<left>" "<enter>"

wait_for_guest_additions_run_level "${VM}" 1

sleep 60

VBoxManage storageattach "${VM}" --storagectl "IDE Controller" --port 1 --device 1 --type dvddrive --medium emptydrive

# Press Win+R
send_keys 4 "<winPress>" r "<winRelease>"

sleep 10

# Enter shutdown /r /t 0 and press ENTER
send_keys 14 "shutdown /r /t 0" "<enter>"

wait_for_guest_additions_run_level "${VM}" 3

sleep 60

# Press Win+R so we can open the \\vboxsrv directory and execute our batch
# script from there.
send_keys 4 "<winPress>" r "<winRelease>"

sleep 10

send_keys 14 "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat" "<enter>"

sleep 60

# select Yes on UAC
send_keys 14 "<left>" "<enter>"

sleep 240

wait_for_vm_to_shutdown "${VM}" 1200

vagrant up "${box_name}" --provision
vagrant reload "${box_name}" --provision
vagrant halt "${box_name}"

package_vm "${1}"
