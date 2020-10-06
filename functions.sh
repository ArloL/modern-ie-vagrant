#!/bin/sh

set -o errexit
set -o nounset

get_guest_additions_run_level() {
    GuestAdditionsRunLevel=0
    eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
    echo ${GuestAdditionsRunLevel}
}

wait_for_guest_additions_run_level() {
    while true ; do
        echo "Waiting for ${1} to be in guest additions run level ${2}."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level "${1}")
        if [ "${GuestAdditionsRunLevel}" -eq "${2}" ]; then
            return 0;
        fi
        sleep 5
    done
}

send_keys() {
    uuid="${1}"
    shift
    for key in "$@"; do
        case $key in
            "<esc>") hexValues="01 81";;
            "<enter>") hexValues="1c 9c";;
            "<winPress>") hexValues="e0 5b";;
            "<winRelease>") hexValues="e0 db";;
            "<left>") hexValues="e0 4b e0 cb";;
            "<altPress>") hexValues="38";;
            "<altRelease>") hexValues="b8";;
            "<shiftPress>") hexValues="2a";;
            "<shiftRelease>") hexValues="aa";;
            "<tab>") hexValues="0f 8f";;
            "\\") hexValues="2b ab";;
            "/") hexValues="35 b5";;
            " ") hexValues="39 b9";;
            ":") hexValues="2a 27 a7 aa";;
            ";") hexValues="27 a7";;
            "!") hexValues="2a 02 82 aa";;
            "a") hexValues="1e 9e";;
            "b") hexValues="30 b0";;
            "c") hexValues="2e ae";;
            "d") hexValues="20 a0";;
            "e") hexValues="12 92";;
            "f") hexValues="21 a1";;
            "g") hexValues="22 a2";;
            "h") hexValues="23 a3";;
            "i") hexValues="17 97";;
            "j") hexValues="24 a4";;
            "k") hexValues="25 a5";;
            "l") hexValues="26 a6";;
            "m") hexValues="32 b2";;
            "n") hexValues="31 b1";;
            "o") hexValues="18 98";;
            "p") hexValues="19 99";;
            "q") hexValues="10 90";;
            "r") hexValues="13 93";;
            "s") hexValues="1f 9f";;
            "t") hexValues="14 94";;
            "u") hexValues="16 96";;
            "v") hexValues="2f af";;
            "w") hexValues="11 91";;
            "x") hexValues="2d ad";;
            "y") hexValues="15 95";;
            "z") hexValues="2c ac";;
            "P") hexValues="2a 19 99 aa";;
            "S") hexValues="2a 1f 9f aa";;
            "0") hexValues="0b 8b";;
            "1") hexValues="02 82";;
            "2") hexValues="03 83";;
            "3") hexValues="04 84";;
            "4") hexValues="05 85";;
            "5") hexValues="06 86";;
            "6") hexValues="07 87";;
            "7") hexValues="08 88";;
            "8") hexValues="09 89";;
            "9") hexValues="0a 8a";;
            *) echo "Sorry, I can not enter ${key} for you!"; exit 1;;
        esac
        VBoxManage controlvm "${uuid}" keyboardputscancode "${hexValues}"
    done
    unset uuid
}

