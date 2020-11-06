#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

BOX_NAME="${1:-win7-ie8}"
GUEST_ADDITIONS_INSTALL_MODE="${2:-auto}"

trap 'vm_halt' EXIT

vm_import
vm_snapshot_delete_all

step=1
while true ; do
    nextStep=$((step + 1))
    if [ "${GUEST_ADDITIONS_INSTALL_MODE}" = "auto" ] &&
            [ "${step}" = 2 ]; then
        nextStep=6
    fi
    if ! vm_snapshot_exists "Snapshot ${step}"; then
        case $step in
        1)
            vm_snapshot_restore_and_up "Pre-Boot"
            sleep 180
            if [ "$(get_guest_additions_run_level)" -gt "0" ]; then
                wait_for_guest_additions_run_level 2 600
            fi
            ;;
        2)
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" "<enter>" "<esc>"
            sleep 180
            if [ "$(get_guest_additions_run_level)" -gt "0" ]; then
                wait_for_guest_additions_run_level 3 600
            fi
            vm_close_dialogs 120
            ;;
        3)
            vm_run_elevate unprovision
            wait_for_vm_to_shutdown 1200
            ;;
        4)
            vm_up
            sleep 180
            ;;
        5)
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" "<enter>" "<esc>"
            sleep 180
            vm_close_dialogs 120
            ;;
        6)
            vm_run_elevate provision
            wait_for_vm_to_shutdown 1200
            vm_network_connection 1 on
            vagrant up "${BOX_NAME}" --provision
            ;;
        7)
            vagrant reload "${BOX_NAME}" --provision
            vagrant halt "${BOX_NAME}"
            ;;
        8)
            vm_package
            exit 0
            ;;
        esac
        vm_snapshot_save "Snapshot ${step}"
    else
        vm_snapshot_restore_and_up "Snapshot ${step}" "Snapshot ${nextStep}"
    fi
    step=${nextStep}
done
