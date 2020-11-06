#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

BOX_NAME="${1:-win7-ie8}"
GUEST_ADDITIONS_INSTALL_MODE="${2:-auto}"

trap 'vm_halt' EXIT

vm_import

if ! vm_snapshot_exists "Snapshot 0"; then
    vm_snapshot_restore_and_up "Pre-Boot"
    sleep 180
    if [ "$(get_guest_additions_run_level)" -gt "0" ]; then
        wait_for_guest_additions_run_level 2 600
    fi
    vm_snapshot_save "Snapshot 0"
else
    if [ "${GUEST_ADDITIONS_INSTALL_MODE}" = "manual" ]; then
        vm_snapshot_restore_and_up "Snapshot 0" "Snapshot 0-1"
    else
        vm_snapshot_restore_and_up "Snapshot 0" "Snapshot 1" "Snapshot 0-1"
    fi
fi

if ! vm_snapshot_exists "Snapshot 1" ||
    [ "${GUEST_ADDITIONS_INSTALL_MODE}" = "manual" ]; then

    if [ "$(get_guest_additions_run_level)" -eq "0" ] ||
        [ "${GUEST_ADDITIONS_INSTALL_MODE}" = "manual" ]; then

        if ! vm_snapshot_exists "Snapshot 0-1"; then
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" "<enter>" "<esc>"
            sleep 180
            if [ "$(get_guest_additions_run_level)" -gt "0" ]; then
                wait_for_guest_additions_run_level 3 600
            fi
            vm_close_dialogs 120
            vm_snapshot_save "Snapshot 0-1"
        else
            vm_snapshot_restore_and_up "Snapshot 0-1" "Snapshot 0-2"
        fi

        if ! vm_snapshot_exists "Snapshot 0-2"; then
            vm_run_elevate unprovision
            wait_for_vm_to_shutdown 1200
            vm_snapshot_save "Snapshot 0-2"
        fi

        if ! vm_snapshot_exists "Snapshot 0-3"; then
            vm_snapshot_restore_and_up "Snapshot 0-2"
            sleep 180
            vm_snapshot_save "Snapshot 0-3"
        else
            vm_snapshot_restore_and_up "Snapshot 0-3" "Snapshot 0-4"
        fi

        if ! vm_snapshot_exists "Snapshot 0-4"; then
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" "<enter>" "<esc>"
            sleep 180
            vm_close_dialogs 120
            vm_snapshot_save "Snapshot 0-4"
        else
            vm_snapshot_restore_and_up "Snapshot 0-4" "Snapshot 0-5"
        fi

        if ! vm_snapshot_exists "Snapshot 0-5"; then
            vm_run_elevate provision
            wait_for_vm_to_shutdown 1200
            vm_snapshot_save "Snapshot 0-5"
        fi

        if ! vm_snapshot_exists "Snapshot 0-6"; then
            vm_snapshot_restore_and_up "Snapshot 0-5"
            wait_for_guest_additions_run_level 2 600
            sleep 180
            vm_snapshot_save "Snapshot 0-6"
        else
            vm_snapshot_restore_and_up "Snapshot 0-6" "Snapshot 1"
        fi

    fi

    if ! vm_snapshot_exists "Snapshot 1"; then
        if [ "$(get_guest_additions_run_level)" -eq "2" ]; then
            # trigger password prompt
            send_keys 14 "<esc>"
            send_keys 1 "Passw0rd!" "<enter>"
            wait_for_guest_additions_run_level 3 600
            sleep 180
        fi
        vm_close_dialogs 120
        vm_snapshot_save "Snapshot 1"
    else
        vm_snapshot_restore_and_up "Snapshot 1" "Snapshot 2"
    fi

else
    vm_snapshot_restore_and_up "Snapshot 1" "Snapshot 2"
fi

if ! vm_snapshot_exists "Snapshot 2"; then
    vm_run_elevate provision
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
