#!/bin/sh

set -o errexit
set -o nounset

get_guest_additions_run_level() {
    GuestAdditionsRunLevel=0
    eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
    echo ${GuestAdditionsRunLevel}
}

wait_for_vm_to_shutdown() {
    timeout=${2}
    while true ; do
        echo "Waiting for ${1} to be in guest additions run level 0."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level "${1}")
        if [ "${GuestAdditionsRunLevel}" -eq "0" ]; then
            return 0;
        fi
        if [ "${timeout}" -le 0 ]; then
            return 1
        fi
        timeout=$((timeout - 10))
        sleep 10
    done
}

wait_for_guest_additions_run_level() {
    timeout=${3}
    while true ; do
        echo "Waiting for ${1} to be in guest additions run level ${2}."
        GuestAdditionsRunLevel=$(get_guest_additions_run_level "${1}")
        if [ "${GuestAdditionsRunLevel}" -ge "${2}" ]; then
            return 0;
        fi
        if [ "${timeout}" -le 0 ]; then
            return 1
        fi
        timeout=$((timeout - 10))
        sleep 10
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
    stringToSplit="${1}"
    while [ -n "$stringToSplit" ]; do
        restOfString="${stringToSplit#?}" # All but the first character of the string
        firstCharacterOfString="${stringToSplit%"$restOfString"}" # Remove $rest so the first character remains
        case $firstCharacterOfString in
            "\\") send_keys_as_hex 2b ab;;
            "/") send_keys_as_hex 35 b5;;
            " ") send_keys_as_hex 39 b9;;
            ":")
                send_keys "<shiftPress>"
                send_keys ";"
                send_keys "<shiftRelease>"
                ;;
            ";") send_keys_as_hex 27 a7;;
            "!")
                send_keys "<shiftPress>"
                send_keys "1"
                send_keys "<shiftRelease>"
                ;;
            "-") send_keys_as_hex 0c 8c;;
            ".") send_keys_as_hex 34 b4;;
            "'") send_keys_as_hex 28 a8;;
            "\"")
                send_keys "<shiftPress>"
                send_keys "'"
                send_keys "<shiftRelease>"
                ;;
            "&")
                send_keys "<shiftPress>"
                send_keys "7"
                send_keys "<shiftRelease>"
                ;;
            "[")
                send_keys_as_hex 1a 9a
                ;;
            "]")
                send_keys_as_hex 1b 9b
                ;;
            "{")
                send_keys "<shiftPress>"
                send_keys "["
                send_keys "<shiftRelease>"
                ;;
            "}")
                send_keys "<shiftPress>"
                send_keys "]"
                send_keys "<shiftRelease>"
                ;;
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
            "A")
                send_keys "<shiftPress>"
                send_keys "a"
                send_keys "<shiftRelease>"
                ;;
            "B")
                send_keys "<shiftPress>"
                send_keys "b"
                send_keys "<shiftRelease>"
                ;;
            "C")
                send_keys "<shiftPress>"
                send_keys "c"
                send_keys "<shiftRelease>"
                ;;
            "D")
                send_keys "<shiftPress>"
                send_keys "d"
                send_keys "<shiftRelease>"
                ;;
            "E")
                send_keys "<shiftPress>"
                send_keys "e"
                send_keys "<shiftRelease>"
                ;;
            "F")
                send_keys "<shiftPress>"
                send_keys "f"
                send_keys "<shiftRelease>"
                ;;
            "G")
                send_keys "<shiftPress>"
                send_keys "g"
                send_keys "<shiftRelease>"
                ;;
            "H")
                send_keys "<shiftPress>"
                send_keys "h"
                send_keys "<shiftRelease>"
                ;;
            "I")
                send_keys "<shiftPress>"
                send_keys "i"
                send_keys "<shiftRelease>"
                ;;
            "J")
                send_keys "<shiftPress>"
                send_keys "j"
                send_keys "<shiftRelease>"
                ;;
            "K")
                send_keys "<shiftPress>"
                send_keys "k"
                send_keys "<shiftRelease>"
                ;;
            "L")
                send_keys "<shiftPress>"
                send_keys "l"
                send_keys "<shiftRelease>"
                ;;
            "M")
                send_keys "<shiftPress>"
                send_keys "m"
                send_keys "<shiftRelease>"
                ;;
            "N")
                send_keys "<shiftPress>"
                send_keys "n"
                send_keys "<shiftRelease>"
                ;;
            "O")
                send_keys "<shiftPress>"
                send_keys "o"
                send_keys "<shiftRelease>"
                ;;
            "P")
                send_keys "<shiftPress>"
                send_keys "p"
                send_keys "<shiftRelease>"
                ;;
            "Q")
                send_keys "<shiftPress>"
                send_keys "q"
                send_keys "<shiftRelease>"
                ;;
            "R")
                send_keys "<shiftPress>"
                send_keys "r"
                send_keys "<shiftRelease>"
                ;;
            "S")
                send_keys "<shiftPress>"
                send_keys "s"
                send_keys "<shiftRelease>"
                ;;
            "T")
                send_keys "<shiftPress>"
                send_keys "t"
                send_keys "<shiftRelease>"
                ;;
            "U")
                send_keys "<shiftPress>"
                send_keys "u"
                send_keys "<shiftRelease>"
                ;;
            "V")
                send_keys "<shiftPress>"
                send_keys "v"
                send_keys "<shiftRelease>"
                ;;
            "W")
                send_keys "<shiftPress>"
                send_keys "w"
                send_keys "<shiftRelease>"
                ;;
            "X")
                send_keys "<shiftPress>"
                send_keys "x"
                send_keys "<shiftRelease>"
                ;;
            "Y")
                send_keys "<shiftPress>"
                send_keys "y"
                send_keys "<shiftRelease>"
                ;;
            "Z")
                send_keys "<shiftPress>"
                send_keys "z"
                send_keys "<shiftRelease>"
                ;;
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
}

send_keys() {
    for key in "$@"; do
        case $key in
            "<esc>") send_keys_as_hex 01 81;;
            "<enter>") send_keys_as_hex 1c 9c;;
            "<winPress>") send_keys_as_hex e0 5b;;
            "<winRelease>") send_keys_as_hex e0 db;;
            "<left>") send_keys_as_hex 4b cb;;
            "<right>") send_keys_as_hex 4d cd;;
            "<up>") send_keys_as_hex 48 c8;;
            "<down>") send_keys_as_hex 50 d0;;
            "<altPress>") send_keys_as_hex 38;;
            "<altRelease>") send_keys_as_hex b8;;
            "<shiftPress>") send_keys_as_hex 2a;;
            "<shiftRelease>") send_keys_as_hex aa;;
            "<tab>") send_keys_as_hex 0f 8f;;
            *) send_keys_split_string "${key}";;
        esac
        sleep 4
    done
}

# VM="\"\${VM}\""
# send_keys "shutdown /r /t 0" "<enter>"
