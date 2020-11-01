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

if ! vm_snapshot_exists "Pre-Boot"; then
    vagrant destroy "${BOX_NAME}" --force
    boot_timeout=1 vagrant up "${BOX_NAME}" || true
    vagrant halt "${BOX_NAME}" --force
    # shellcheck disable=SC2034
    VM=$(cat ".vagrant/machines/${BOX_NAME}/virtualbox/id")
fi

if ! vm_snapshot_exists "Snapshot 0"; then

    vm_snapshot_restore "Pre-Boot"

    reset_storage_controller

    boot_timeout=15 vagrant up "${BOX_NAME}" || true

    wait_for_guest_additions_run_level 2 600

    sleep 120

    vagrant snapshot save "${BOX_NAME}" "Snapshot 0"

else
    vm_snapshot_restore "Snapshot 0"
    boot_timeout=15 vagrant up "${BOX_NAME}" || true
fi

GuestAdditionsRunLevel=$(get_guest_additions_run_level)

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
