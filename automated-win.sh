#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

BOX_NAME="${1:-win7-ie8}"

# We want the variable to expand when setting the trap
# shellcheck disable=SC2064
trap "vagrant halt ${BOX_NAME} --force" EXIT

if [ -f ".vagrant/machines/${BOX_NAME}/virtualbox/id" ]; then
    VM=$(cat ".vagrant/machines/${BOX_NAME}/virtualbox/id")
else
    VM=""
fi

if [ "${VM}" != "" ] && VBoxManage snapshot "${VM}" list; then

    VBoxManage modifyvm "${VM}" \
        --recording "on" \
        --recordingfile "recordings/${BOX_NAME}-$(date -u +"%Y%m%dT%H%M%S").webm"

    boot_timeout=15 vagrant snapshot restore "${BOX_NAME}" "Snapshot 0" || true

else

    boot_timeout=15 vagrant up "${BOX_NAME}" || true

    VM=$(cat ".vagrant/machines/${BOX_NAME}/virtualbox/id")

    wait_for_guest_additions_run_level 2 600

    sleep 120

    vagrant snapshot save "${BOX_NAME}" "Snapshot 0"

fi

GuestAdditionsRunLevel=$(get_guest_additions_run_level "${VM}")

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    send_keys 14 "<enter>"

    send_keys 1 "Passw0rd!" "<enter>"

    wait_for_guest_additions_run_level 3 600

    sleep 120

fi

# close restart dialog
send_keys 14 "<esc>"

run_command "\\\\vboxsrv\\vagrant\\scripts\\elevate-provision.bat"

sleep 73

case ${BOX_NAME} in
    win7*)
        # select Yes on question whether to run script
        send_keys 14 "<left>" "<enter>"
        sleep 60
        ;;
esac

# select Yes on UAC
send_keys 14 "<left>" "<enter>"

sleep 240

wait_for_vm_to_shutdown 1200

vagrant up "${BOX_NAME}" --provision
vagrant reload "${BOX_NAME}" --provision
vagrant halt "${BOX_NAME}"

package_vm "${BOX_NAME}"
