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

    # close all dialogs or trigger password prompt
    send_keys 14 "<esc>" "<esc>" "<esc>"

    send_keys 1 "Passw0rd!" "<enter>"

    # wait and close all upcoming dialogs
    send_keys 14 "<esc>" "<esc>" "<esc>" "<esc>" "<esc>" "<esc>" "<esc>" "<esc>"

    sleep 30

    vagrant snapshot save "${BOX_NAME}" "Snapshot 0"

else
    vm_snapshot_restore "Snapshot 0"
    boot_timeout=15 vagrant up "${BOX_NAME}" || true
fi

if ! vm_snapshot_exists "Snapshot 1"; then

    case ${BOX_NAME} in
        win7*)
            run_command 'cmd /c "e:\vboxwindowsadditions /S && shutdown /s /t 0 /f"'
            sleep 73
            # select Yes on UAC
            send_keys 14 "<left>" "<enter>"
            sleep 15
            # switch to driver window
            send_keys 1 "<altPress>" "<tab>" "<tab>" "<altRelease>"
            sleep 13
            # select always trust and Yes to add driver
            send_keys 14 "<left>" "<left>" "<space>" "<right>" "<enter>"
            ;;
        win10*)
            run_command 'cmd /c "d:\vboxwindowsadditions /S && shutdown /s /t 0 /f"'
            sleep 73
            # select Yes on UAC
            send_keys 14 "<left>" "<enter>"
            sleep 15
            # switch to driver window
            send_keys 1 "<altPress>" "<tab>" "<altRelease>"
            # select Yes to add driver
            send_keys 14 "<left>" "<enter>"
            ;;
    esac

    wait_for_vm_to_shutdown 1200

    vagrant snapshot save "${BOX_NAME}" "Snapshot 1"

else
    vm_snapshot_restore "Snapshot 1"
fi

boot_timeout=15 vagrant up "${BOX_NAME}" || true

wait_for_guest_additions_run_level 2 600

sleep 120

GuestAdditionsRunLevel=$(get_guest_additions_run_level)

if [ "${GuestAdditionsRunLevel}" -eq "2" ]; then

    send_keys 14 "<enter>" "Passw0rd!" "<enter>"

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
