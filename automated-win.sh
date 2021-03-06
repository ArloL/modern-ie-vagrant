#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

box_name="${1:-win7-ie8}"
install_mode="${2:-auto}"

trap 'vm_halt' EXIT

vm_import

if [ "${3:-}" = "reset" ]; then
    vm_snapshot_delete_all
fi

step=1
while true ; do
    next_step=$((step + 1))
    if [ "${install_mode}" = "auto" ] &&
            [ "${step}" = 2 ]; then
        next_step=6
    fi
    if ! vm_snapshot_exists "Snapshot ${step}"; then
        case $step in
        1)
            vm_snapshot_restore_and_up "Pre-Boot"
            sleep 180
            if [ "$(get_guest_additions_run_level)" -gt "0" ]; then
                wait_for_guest_additions_run_level 2 600
            fi
            sleep 180
            ;;
        2)
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" \
                "<enter>" "<esc>"
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
            send_keys 1 "<esc>" "<win>" "Passw0rd!" "<esc>" "<win>" \
                "<enter>" "<esc>"
            sleep 180
            vm_close_dialogs 120
            ;;
        6)
            vm_run_elevate provision
            wait_for_vm_to_shutdown 1200
            vm_network_connection 1 on
            vagrant up "${box_name}" --provision
            ;;
        7)
            vagrant provision "${box_name}" --provision-with "chocolatey"
            wait_for_vm_to_shutdown 1200
            vagrant up "${box_name}"
            ;;
        8)
            vagrant provision "${box_name}" --provision-with "updates"
            wait_for_vm_to_shutdown 1200
            vagrant up "${box_name}"
            ;;
        9)
            vagrant provision "${box_name}" --provision-with "updates"
            wait_for_vm_to_shutdown 1200
            vagrant up "${box_name}"
            ;;
        10)
            vagrant provision "${box_name}" --provision-with "updates"
            wait_for_vm_to_shutdown 1200
            vagrant up "${box_name}"
            ;;
        11)
            while true ; do
                vagrant provision "${box_name}" --provision-with "updates"
                state=$(cat "update-state-${box_name}.log")
                rm -f "update-state-${box_name}.log"
                wait_for_vm_to_shutdown 1200
                vagrant up "${box_name}"
                if [ "${state}" = "done" ]; then
                    break
                fi
            done
            ;;
        12)
            vagrant reload "${box_name}" --provision
            vagrant halt "${box_name}"
            ;;
        13)
            vm_package
            exit 0
            ;;
        esac
        vm_snapshot_save "Snapshot ${step}"
    else
        vm_snapshot_restore_and_up "Snapshot ${step}" "Snapshot ${next_step}"
    fi
    step=${next_step}
done
