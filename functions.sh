#!/bin/bash

set -o errexit
set -o nounset

run_command() {
    send_keys 1 "<winPress>" r "<winRelease>"
    sleep 13
    send_keys 1 "${1}" "<enter>"
}

vm_snapshot_exists() {
    if [ "${VM}" != "" ] && \
        VBoxManage snapshot "${VM}" showvminfo "${1}" > /dev/null 2>&1;
    then
        return 0;
    fi
    return 1
}

vm_snapshot_restore() {
    vagrant snapshot restore "${BOX_NAME}" "${1}"  --no-start
    VBoxManage modifyvm "${VM}" \
        --recordingfile \
        "recordings/${BOX_NAME}-$(date -u +"%Y%m%dT%H%M%S").webm"
}

reset_storage_controller() {
    local ImageUUID
    ImageUUID="$(VBoxManage showvminfo "${VM}" --machinereadable | grep 'ImageUUID' | awk -F '"' '{ print $4 }')"

    if [ "${ImageUUID}" = "" ]; then
        echo "Could not find ImageUUID"
        return 1
    fi

    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 0 --medium none || true
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --medium none || true
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 1 --device 0 --medium none || true
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 1 --device 1 --medium none || true

    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 0 --type hdd --medium "${ImageUUID}"
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium emptydrive
}

reset_vm_state() {
    VBoxManage setextradata "${VM}" "GUI/Fullscreen"
    VBoxManage setextradata "${VM}" "GUI/LastCloseAction"
    VBoxManage setextradata "${VM}" "GUI/LastGuestSizeHint"
    VBoxManage setextradata "${VM}" "GUI/LastNormalWindowPosition"
    VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeDevicesMenuActions"
    VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeMachineMenuActions"
    VBoxManage setextradata "${VM}" "GUI/ScaleFactor"
    VBoxManage setextradata "${VM}" "GUI/StatusBar/IndicatorOrder"
}

package_vm() {
    VBoxManage modifyvm "${VM}" --recording off
    reset_vm_state
    vagrant package "${BOX_NAME}" \
        --output "${BOX_NAME}.box" \
        --Vagrantfile Vagrantfile-package
    vagrant box add --name "okeeffe-${BOX_NAME}" --force "${BOX_NAME}.box"
    rm -f "${BOX_NAME}.box"
}

get_guest_additions_run_level() {
    local GuestAdditionsRunLevel=0
    eval "$(VBoxManage showvminfo "${VM}" \
        --machinereadable | grep 'GuestAdditionsRunLevel')"
    echo ${GuestAdditionsRunLevel}
}

wait_for_vm_to_shutdown() {
    local timeout=${1}
    while true ; do
        echo "Waiting for ${VM} to be in guest additions run level 0."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level)
        if [ "${GuestAdditionsRunLevel}" -eq "0" ]; then
            return 0;
        fi
        if [ "${timeout}" -le 0 ]; then
            return 1
        fi
        timeout=$((timeout - 15))
        sleep 15
    done
}

wait_for_guest_additions_run_level() {
    local timeout=${2}
    while true ; do
        echo "Waiting for ${VM} to be in guest additions run level ${1}."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level)
        if [ "${GuestAdditionsRunLevel}" -ge "${1}" ]; then
            return 0;
        fi
        if [ "${timeout}" -le 0 ]; then
            return 1
        fi
        timeout=$((timeout - 15))
        sleep 15
    done
}

send_keys_as_hex() {
    VBoxManage controlvm "${VM}" keyboardputscancode "$@"
    sleep 1
}

# The table https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
# shows the press scan code. To calculate release add 0x80 to the press code.
# For example Left-Shift is calculated as follows:
# 0x80 + 0x2a = 0xaa -> 2a aa
send_keys_split_string() {
    local stringToSplit=${1}
    while [ -n "${stringToSplit}" ]; do
        local restOfString="${stringToSplit#?}" # All but the first character of the string
        local firstCharacterOfString="${stringToSplit%"${restOfString}"}" # Remove rest so the first character remains
        case ${firstCharacterOfString} in
            "\\") send_keys_as_hex 2b ab;;
            "/") send_keys_as_hex 35 b5;;
            " ") send_keys_as_hex 39 b9;;
            ":") send_keys 1 "<shiftPress>" ";" "<shiftRelease>";;
            ";") send_keys_as_hex 27 a7;;
            "!") send_keys 1 "<shiftPress>" "1" "<shiftRelease>";;
            "-") send_keys_as_hex 0c 8c;;
            ".") send_keys_as_hex 34 b4;;
            "'") send_keys_as_hex 28 a8;;
            "\"") send_keys 1 "<shiftPress>" "'" "<shiftRelease>";;
            "&") send_keys 1 "<shiftPress>" "7" "<shiftRelease>";;
            "[") send_keys_as_hex 1a 9a;;
            "]") send_keys_as_hex 1b 9b;;
            "{") send_keys 1 "<shiftPress>" "[" "<shiftRelease>";;
            "}") send_keys 1 "<shiftPress>" "]" "<shiftRelease>";;
            "a") send_keys_as_hex 1e 9e;;
            "b") send_keys_as_hex 30 b0;;
            "c") send_keys_as_hex 2e ae;;
            "d") send_keys_as_hex 20 a0;;
            "e") send_keys_as_hex 12 92;;
            "f") send_keys_as_hex 21 a1;;
            "g") send_keys_as_hex 22 a2;;
            "h") send_keys_as_hex 23 a3;;
            "i") send_keys_as_hex 17 97;;
            "j") send_keys_as_hex 24 a4;;
            "k") send_keys_as_hex 25 a5;;
            "l") send_keys_as_hex 26 a6;;
            "m") send_keys_as_hex 32 b2;;
            "n") send_keys_as_hex 31 b1;;
            "o") send_keys_as_hex 18 98;;
            "p") send_keys_as_hex 19 99;;
            "q") send_keys_as_hex 10 90;;
            "r") send_keys_as_hex 13 93;;
            "s") send_keys_as_hex 1f 9f;;
            "t") send_keys_as_hex 14 94;;
            "u") send_keys_as_hex 16 96;;
            "v") send_keys_as_hex 2f af;;
            "w") send_keys_as_hex 11 91;;
            "x") send_keys_as_hex 2d ad;;
            "y") send_keys_as_hex 15 95;;
            "z") send_keys_as_hex 2c ac;;
            "A") send_keys 1 "<shiftPress>" "a" "<shiftRelease>";;
            "B") send_keys 1 "<shiftPress>" "b" "<shiftRelease>";;
            "C") send_keys 1 "<shiftPress>" "c" "<shiftRelease>";;
            "D") send_keys 1 "<shiftPress>" "d" "<shiftRelease>";;
            "E") send_keys 1 "<shiftPress>" "e" "<shiftRelease>";;
            "F") send_keys 1 "<shiftPress>" "f" "<shiftRelease>";;
            "G") send_keys 1 "<shiftPress>" "g" "<shiftRelease>";;
            "H") send_keys 1 "<shiftPress>" "h" "<shiftRelease>";;
            "I") send_keys 1 "<shiftPress>" "i" "<shiftRelease>";;
            "J") send_keys 1 "<shiftPress>" "j" "<shiftRelease>";;
            "K") send_keys 1 "<shiftPress>" "k" "<shiftRelease>";;
            "L") send_keys 1 "<shiftPress>" "l" "<shiftRelease>";;
            "M") send_keys 1 "<shiftPress>" "m" "<shiftRelease>";;
            "N") send_keys 1 "<shiftPress>" "n" "<shiftRelease>";;
            "O") send_keys 1 "<shiftPress>" "o" "<shiftRelease>";;
            "P") send_keys 1 "<shiftPress>" "p" "<shiftRelease>";;
            "Q") send_keys 1 "<shiftPress>" "q" "<shiftRelease>";;
            "S") send_keys 1 "<shiftPress>" "s" "<shiftRelease>";;
            "T") send_keys 1 "<shiftPress>" "t" "<shiftRelease>";;
            "U") send_keys 1 "<shiftPress>" "u" "<shiftRelease>";;
            "V") send_keys 1 "<shiftPress>" "v" "<shiftRelease>";;
            "W") send_keys 1 "<shiftPress>" "w" "<shiftRelease>";;
            "X") send_keys 1 "<shiftPress>" "x" "<shiftRelease>";;
            "Y") send_keys 1 "<shiftPress>" "y" "<shiftRelease>";;
            "Z") send_keys 1 "<shiftPress>" "z" "<shiftRelease>";;
            "0") send_keys_as_hex 0b 8b;;
            "1") send_keys_as_hex 02 82;;
            "2") send_keys_as_hex 03 83;;
            "3") send_keys_as_hex 04 84;;
            "4") send_keys_as_hex 05 85;;
            "5") send_keys_as_hex 06 86;;
            "6") send_keys_as_hex 07 87;;
            "7") send_keys_as_hex 08 88;;
            "8") send_keys_as_hex 09 89;;
            "9") send_keys_as_hex 0a 8a;;
            *) echo "${firstCharacterOfString} is not mapped!"; exit 1;;
        esac
        stringToSplit="${restOfString}"
    done
}

send_keys() {
    local timeout=${1}
    shift
    for key in "$@"; do
        case ${key} in
            "<esc>") send_keys_as_hex 01 81;;
            "<enter>") send_keys_as_hex 1c 9c;;
            "<space>") send_keys_split_string " ";;
            "<winPress>") send_keys_as_hex e0 5b;;
            "<winRelease>") send_keys_as_hex e0 db;;
            "<left>") send_keys_as_hex e0 4b e0 cb;;
            "<right>") send_keys_as_hex e0 4d e0 cd;;
            "<up>") send_keys_as_hex e0 48 e0 c8;;
            "<down>") send_keys_as_hex e0 50 e0 d0;;
            "<altPress>") send_keys_as_hex 38;;
            "<altRelease>") send_keys_as_hex b8;;
            "<shiftPress>") send_keys_as_hex 2a;;
            "<shiftRelease>") send_keys_as_hex aa;;
            "<tab>") send_keys_as_hex 0f 8f;;
            "<f1>") send_keys_as_hex 3b bb;;
            "<f2>") send_keys_as_hex 3c bc;;
            "<f3>") send_keys_as_hex 3d bd;;
            "<f4>") send_keys_as_hex 3e be;;
            "<f5>") send_keys_as_hex 3f bf;;
            "<f6>") send_keys_as_hex 40 c0;;
            "<f7>") send_keys_as_hex 41 c1;;
            "<f8>") send_keys_as_hex 42 c2;;
            "<f9>") send_keys_as_hex 43 c3;;
            "<f10>") send_keys_as_hex 44 c4;;
            *) send_keys_split_string "${key}";;
        esac
        sleep "${timeout}"
    done
}

# VM="\"\${VM}\""
# send_keys 10 "shutdown /r /t 0" "<enter>"
