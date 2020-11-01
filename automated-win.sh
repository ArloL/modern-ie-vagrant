#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

BOX_NAME="${1:-win7-ie8}"
GUEST_ADDITIONS_INSTALL_MODE="${2:-auto}"
# shellcheck disable=SC2034
VM=$(vm_id)

trap 'vagrant halt "${BOX_NAME}" --force' EXIT

vm_import

if ! vm_snapshot_exists "Snapshot 0"; then
    vm_snapshot_restore "Pre-Boot"
    reset_storage_controller
    vm_up
    sleep 120
    vm_snapshot_save "Snapshot 0"
else
    vm_snapshot_restore_and_up "Snapshot 0" "Snapshot 1" "Snapshot 0-1"
fi

if ! vm_snapshot_exists "Snapshot 1"; then

    if [ "${GUEST_ADDITIONS_INSTALL_MODE}" = "manual" ] ||
        [ "$(get_guest_additions_run_level)" -eq "0" ]; then

        if ! vm_snapshot_exists "Snapshot 0-1"; then
            # close dialog or trigger password prompt
            send_keys 14 "<esc>"
            send_keys 1 "Passw0rd!" "<enter>"
            # wait for 180 seconds while closing upcoming dialogs
            send_keys 14 \
                "<esc>" "<esc>" "<esc>" "<esc>" \
                "<esc>" "<esc>" "<esc>" "<esc>" \
                "<esc>" "<esc>" "<esc>" "<esc>"
            vm_snapshot_save "Snapshot 0-1"
        else
            vm_snapshot_restore_and_up "Snapshot 0-1" "Snapshot 0-2"
        fi

        if ! vm_snapshot_exists "Snapshot 0-2"; then
            vm_run_guest_additions_install
            wait_for_vm_to_shutdown 1200
            vm_snapshot_save "Snapshot 0-2"
        else
            vm_snapshot_restore "Snapshot 0-2" "Snapshot 0-3"
        fi

        if ! vm_snapshot_exists "Snapshot 0-3"; then
            vm_up
            wait_for_guest_additions_run_level 2 600
            sleep 120
            vm_snapshot_save "Snapshot 0-3"
        else
            vm_snapshot_restore_and_up "Snapshot 0-3"
        fi

    fi

    if [ "$(get_guest_additions_run_level)" -eq "2" ]; then
        # trigger password prompt
        send_keys 14 "<esc>"
        send_keys 1 "Passw0rd!" "<enter>"
        wait_for_guest_additions_run_level 3 600
    fi

    # wait for 180 seconds while closing upcoming dialogs
    send_keys 14 \
        "<esc>" "<esc>" "<esc>" "<esc>" \
        "<esc>" "<esc>" "<esc>" "<esc>" \
        "<esc>" "<esc>" "<esc>" "<esc>"

    vm_snapshot_save "Snapshot 1"

else
    vm_snapshot_restore_and_up "Snapshot 1" "Snapshot 2"
fi

if ! vm_snapshot_exists "Snapshot 2"; then
    vm_run_provisioning
    sleep 240
    wait_for_vm_to_shutdown 1200
    vm_snapshot_save "Snapshot 2"
else
    vm_snapshot_restore "Snapshot 2" "Snapshot 3"
fi

if ! vm_snapshot_exists "Snapshot 3"; then
    vagrant up "${BOX_NAME}" --provision
    vagrant reload "${BOX_NAME}" --provision
    vagrant halt "${BOX_NAME}"
    vm_snapshot_save "Snapshot 3"
else
    vm_snapshot_restore "Snapshot 3"
fi

vm_package "${BOX_NAME}"
