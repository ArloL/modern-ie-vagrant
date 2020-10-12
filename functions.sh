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

send_keys_as_hex() {
    VBoxManage controlvm "${VM}" keyboardputscancode "$@"
}

send_keys_split_string() {
    stringToSplit="${1}"
    while [ -n "$stringToSplit" ]; do
        restOfString="${stringToSplit#?}" # All but the first character of the string
        firstCharacterOfString="${stringToSplit%"$restOfString"}" # Remove $rest so the first character remains
        case $firstCharacterOfString in
            "\\") send_keys_as_hex 2b ab;;
            "/") send_keys_as_hex 35 b5;;
            " ") send_keys_as_hex 39 b9;;
            ":") send_keys_as_hex 2a 27 a7 aa;;
            ";") send_keys_as_hex 27 a7;;
            "!") send_keys_as_hex 2a 02 82 aa;;
            "-") send_keys_as_hex 0c 8c;;
            ".") send_keys_as_hex 34 b4;;
            "\"") send_keys_as_hex ;;
            "&") send_keys_as_hex 2a 08 88 aa;;
            "{") send_keys_as_hex 2a 1a 9a aa;;
            "}") send_keys_as_hex 2a 1b 9b aa;;
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
            "A") send_keys_as_hex 2a 1e 9e aa;;
            "B") send_keys_as_hex 2a 30 b0 aa;;
            "C") send_keys_as_hex 2a 2e ae aa;;
            "D") send_keys_as_hex 2a 20 a0 aa;;
            "E") send_keys_as_hex 2a 12 92 aa;;
            "F") send_keys_as_hex 2a 21 a1 aa;;
            "G") send_keys_as_hex 2a 22 a2 aa;;
            "H") send_keys_as_hex 2a 23 a3 aa;;
            "I") send_keys_as_hex 2a 17 97 aa;;
            "J") send_keys_as_hex 2a 24 a4 aa;;
            "K") send_keys_as_hex 2a 25 a5 aa;;
            "L") send_keys_as_hex 2a 26 a6 aa;;
            "M") send_keys_as_hex 2a 32 b2 aa;;
            "N") send_keys_as_hex 2a 31 b1 aa;;
            "O") send_keys_as_hex 2a 18 98 aa;;
            "P") send_keys_as_hex 2a 19 99 aa;;
            "Q") send_keys_as_hex 2a 10 90 aa;;
            "R") send_keys_as_hex 2a 13 93 aa;;
            "S") send_keys_as_hex 2a 1f 9f aa;;
            "T") send_keys_as_hex 2a 14 94 aa;;
            "U") send_keys_as_hex 2a 16 96 aa;;
            "V") send_keys_as_hex 2a 2f af aa;;
            "W") send_keys_as_hex 2a 11 91 aa;;
            "X") send_keys_as_hex 2a 2d ad aa;;
            "Y") send_keys_as_hex 2a 15 95 aa;;
            "Z") send_keys_as_hex 2a 2c ac aa;;
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
            *) echo "Sorry, I can not enter ${firstCharacterOfString} for you!"; exit 1;;
        esac
        stringToSplit="$restOfString"
    done
    unset stringToSplit
    unset restOfString
    unset firstCharacterOfString
}

send_keys() {
    for key in "$@"; do
        case $key in
            "<esc>") send_keys_as_hex 01 81;;
            "<enter>") send_keys_as_hex 1c 9c;;
            "<winPress>") send_keys_as_hex e0 5b;;
            "<winRelease>") send_keys_as_hex e0 db;;
            "<left>") send_keys_as_hex e0 4b e0 cb;;
            "<altPress>") send_keys_as_hex 38;;
            "<altRelease>") send_keys_as_hex b8;;
            "<shiftPress>") send_keys_as_hex 2a;;
            "<shiftRelease>") send_keys_as_hex aa;;
            "<tab>") send_keys_as_hex 0f 8f;;
            *) send_keys_split_string "${key}";;
        esac
    done
}

# VM="\"\${VM}\""
# send_keys "shutdown /r /t 0" "<enter>"
