#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

xtrace_enabled() {
    case $- in
        (*x*) return 0;;
        (*) return 1;;
    esac
}

vm_uuid() {
    #shellcheck disable=SC2154
    if [ -f ".vagrant/machines/${box_name}/virtualbox/id" ]; then
        vm_uuid=$(cat ".vagrant/machines/${box_name}/virtualbox/id")
    else
        vm_uuid=""
    fi
}

vm_import() {
    session_id=$(date -u +"%Y%m%dT%H%M%S")
    vm_uuid
    if ! vm_snapshot_exists "Pre-Boot"; then
        download_box
        download_prerequisites
        vagrant destroy "${box_name}" --force
        X_VAGRANT_TAKE_PRE_BOOT_SNAPSHOT=true \
            X_VAGRANT_BOOT_TIMEOUT=1 \
            vagrant up "${box_name}" || true
        vagrant halt "${box_name}" --force
        vm_uuid
    fi
}

vm_up() {
    if [ "$(vm_state)" = "saved" ]; then
        X_VAGRANT_BOOT_TIMEOUT=15 vagrant up "${box_name}" || true
        vm_storage_attach
    else
        vm_storage_attach
        X_VAGRANT_BOOT_TIMEOUT=15 vagrant up "${box_name}" || true
    fi
}

vm_halt() {
    vagrant halt "${box_name}" --force
    vm_storage_detach
    find "$(pwd)" -maxdepth 1 -type f -name "scripts-${box_name}-*.iso" \
        -exec VBoxManage closemedium dvd {} --delete \;
}

vm_storage_detach() {
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium "emptydrive"
}

vm_storage_attach() {
    vm_storage_detach
    local scripts_iso="scripts-${box_name}-${session_id}.iso"
    if [ ! -f "${scripts_iso}" ]; then
        hdiutil makehybrid -iso -joliet -o "${scripts_iso}" scripts
    fi
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium "${scripts_iso}"
    if [ "$(vm_state)" = "running" ]; then
        vm_close_dialogs 15
    fi
}

vm_snapshot_exists() {
    VBoxManage snapshot "${vm_uuid}" showvminfo "${1}" > /dev/null 2>&1;
}

vm_snapshot_restore_and_up() {
    if [ "${2:-}" != "" ] && vm_snapshot_exists "${2}"; then
        return 0
    fi
    vm_storage_detach
    vagrant snapshot restore "${box_name}" "${1}" --no-start
    VBoxManage modifyvm "${vm_uuid}" \
        --recordingfile \
        "recordings/${box_name}-$(date -u +"%Y%m%dT%H%M%S").webm"
    if [ "${1}" = "Pre-Boot" ]; then
        reset_storage_controller
        vm_network_connection 1 off
        vm_up
    fi
    if [ "$(vm_state)" = "saved" ]; then
        vm_up
    fi
}

vm_snapshot_save() {
    vm_storage_detach
    vagrant snapshot save "${box_name}" "${1}"
    vm_storage_attach
}

vm_snapshot_delete_all() {
    mapfile -t snapshots < <(VBoxManage snapshot "${vm_uuid}" list --machinereadable | grep '^SnapshotName' | awk -F '"' '{ print $2 }')
    for snapshot in "${snapshots[@]}"; do
        if [ "${snapshot}" != "Pre-Boot" ]; then
            VBoxManage snapshot "${vm_uuid}" delete "${snapshot}"
        fi
    done
}

reset_storage_controller() {
    local ImageUUID
    ImageUUID="$(VBoxManage showvminfo "${vm_uuid}" --machinereadable \
        | grep 'ImageUUID' | awk -F '"' '{ print $4 }')"

    if [ "${ImageUUID}" = "" ]; then
        echo "Could not find ImageUUID"
        return 1
    fi

    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 0 --medium none || true
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --medium none || true
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 1 --device 0 --medium none || true
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 1 --device 1 --medium none || true

    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 0 --type hdd --medium "${ImageUUID}"
    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium emptydrive
}

vm_reset() {
    vm_network_connection 1 on

    VBoxManage storageattach "${vm_uuid}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium emptydrive

    VBoxManage setextradata "${vm_uuid}" "GUI/Fullscreen"
    VBoxManage setextradata "${vm_uuid}" "GUI/LastCloseAction"
    VBoxManage setextradata "${vm_uuid}" "GUI/LastGuestSizeHint"
    VBoxManage setextradata "${vm_uuid}" "GUI/LastNormalWindowPosition"
    VBoxManage setextradata "${vm_uuid}" \
        "GUI/RestrictedRuntimeDevicesMenuActions"
    VBoxManage setextradata "${vm_uuid}" \
        "GUI/RestrictedRuntimeMachineMenuActions"
    VBoxManage setextradata "${vm_uuid}" "GUI/ScaleFactor"
    VBoxManage setextradata "${vm_uuid}" "GUI/StatusBar/IndicatorOrder"
}

vm_package() {
    VBoxManage modifyvm "${vm_uuid}" --recording off
    vm_reset
    vagrant package "${box_name}" \
        --output "${box_name}.box" \
        --Vagrantfile Vagrantfile-package
    if [ "${VAGRANT_CLOUD_ACCESS_TOKEN:-}" != "" ] &&
            [ "${X_MIE_VERSION:-}" != "" ] &&
            [ "${X_MIE_VERSION:-}" != "undefined" ]; then
        vm_publish
    fi
    rm -f "${box_name}.box"
}

vm_publish() {
    local xtrace_enabled
    xtrace_enabled=$(xtrace_enabled || true)
    ${xtrace_enabled} && set +o xtrace

    local base_url="https://app.vagrantup.com/api/v1/box/breeze/${box_name}"

    # create version
    curl --verbose --fail \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
        "${base_url}/versions" \
        --data '
            { "version": {
                "version": "'"${X_MIE_VERSION}"'",
                "description": ""
            } }' > /dev/null

    # create provider
    curl --verbose --fail \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
        "${base_url}/version/${X_MIE_VERSION}/providers" \
        --data '{ "provider": { "name": "virtualbox" } }' > /dev/null

    # prepare upload and get upload path
    response=$(curl --verbose --fail \
        --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
        "${base_url}/version/${X_MIE_VERSION}/provider/virtualbox/upload")

    local upload_path
    upload_path=$(echo "$response" | jq -r .upload_path)

    # perform the upload
    curl --verbose --fail \
        --request PUT \
        --upload-file "${box_name}.box" "${upload_path}" && rc=$? || rc=$?
    case ${rc} in
    0)  ;;
    52) ;;
    *)  exit ${rc};;
    esac

    # release the version
    curl --verbose --fail \
        --request PUT \
        --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
        "${base_url}/version/${X_MIE_VERSION}/release"

    ${xtrace_enabled} && set -o xtrace
}

vm_info() {
    VBoxManage showvminfo "${vm_uuid}" --machinereadable \
        | grep "${1}" | awk -F '"' '{ print $'"${2}"' }'
}

vm_state() {
    vm_info "VMState=" 2
}

get_guest_additions_run_level() {
    local GuestAdditionsRunLevel=0
    eval "$(VBoxManage showvminfo "${vm_uuid}" \
        --machinereadable | grep 'GuestAdditionsRunLevel')"
    echo ${GuestAdditionsRunLevel}
}

wait_for_vm_to_shutdown() {
    local timeout=${1}
    while true ; do
        echo "Waiting for ${vm_uuid} to be in VMState poweroff."
        if [ "$(vm_state)" = "poweroff" ]; then
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
        echo "Waiting for ${vm_uuid} to be in guest additions run level ${1}."
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
    VBoxManage controlvm "${vm_uuid}" keyboardputscancode "$@"
    sleep 1
}

# The table https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
# shows the press scan code. To calculate release add 0x80 to the press code.
# For example Left-Shift is calculated as follows:
# 0x80 + 0x2a = 0xaa -> 2a aa
send_keys_split_string() {
    local stringToSplit=${1}
    while [ -n "${stringToSplit}" ]; do
        # All but the first character of the string
        local restOfString="${stringToSplit#?}"
        # Remove rest so the first character remains
        local firstCharacterOfString="${stringToSplit%"${restOfString}"}"
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
            "<win>") send_keys_as_hex e0 5b e0 db;;
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

vm_network_connection() {
    VBoxManage modifyvm "${vm_uuid}" --cableconnected"${1}" "${2}"
}

vm_run_elevate() {
    send_keys 1 "<winPress>" r "<winRelease>"
    sleep 13
    case ${box_name} in
        win7*) send_keys 1 "e:\\elevate.bat e:\\ ${1}";;
        win*) send_keys 1 "d:\\elevate.bat d:\\ ${1}";;
    esac
    send_keys 1 "<enter>"
    sleep 110
    # select Yes on UAC
    send_keys 1 "<left>" "<enter>"
}

vm_close_dialogs() {
    local timeout=${1}
    while true ; do
        send_keys 1 "<esc>" "<altPress>" "<tab>" "<altRelease>" "<esc>"
        if [ "${timeout}" -le 0 ]; then
            return 0
        fi
        timeout=$((timeout - 15))
        sleep 5
    done
}

download_box() {
    local base_url_2015="https://az792536.vo.msecnd.net/vms/VMBuild_20150916"
    local base_url_2019="https://az792536.vo.msecnd.net/vms/VMBuild_20190311"
    case ${box_name} in
    "win7-ie8")
        download "IE8 - Win7.box" \
            "${base_url_2015}/Vagrant/IE8/IE8.Win7.Vagrant.zip";;
    "win7-ie9")
        download "IE9 - Win7.box" \
            "${base_url_2015}/Vagrant/IE9/IE9.Win7.Vagrant.zip";;
    "win7-ie10")
        download "IE10 - Win7.box" \
            "${base_url_2015}/Vagrant/IE10/IE10.Win7.Vagrant.zip";;
    "win7-ie11")
        download "IE11 - Win7.box" \
            "${base_url_2015}/Vagrant/IE11/IE11.Win7.Vagrant.zip";;
    "win81-ie11")
        download "IE11 - Win81.box" \
            "${base_url_2015}/Vagrant/IE11/IE11.Win81.Vagrant.zip";;
    "win10-edge")
        download "MSEdge - Win10.box" \
            "${base_url_2019}/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip";;
    *)
        echo "Sorry, I can not get a VM for you!"
        exit 1;;
    esac
}

download() {
    local unzipped_name=${1}
    local url=${2}
    filtered_box_list=$(vagrant box list | grep "modern.ie/${box_name}" || true)
    if [ ! "${filtered_box_list}" = "" ]
    then
        echo "${box_name} exists"
        return
    fi
    if [ -f "modern.ie-${box_name}.box" ]
    then
        shasum --check "vms/modern.ie-${box_name}.box.sha1"
        vagrant box add --force \
            --name="modern.ie/${box_name}" "modern.ie-${box_name}.box"
        rm -f "modern.ie-${box_name}.box"
        return
    fi
    if ! shasum --check "vms/modern.ie-${box_name}.zip.sha1"
    then
        rm -f "modern.ie-${box_name}.zip"
        wget --quiet  --continue \
            --output-document="modern.ie-${box_name}.zip" "${url}"
        shasum --check "vms/modern.ie-${box_name}.zip.sha1"
    fi
    if [ ! -f "${unzipped_name}" ]
    then
        unzip "modern.ie-${box_name}.zip"
    fi
    mv "${unzipped_name}" "modern.ie-${box_name}.box"
    shasum --check "vms/modern.ie-${box_name}.box.sha1"
    rm -f "modern.ie-${box_name}.zip"
    vagrant box add --force \
        --name="modern.ie/${box_name}" "modern.ie-${box_name}.box"
    rm -f "modern.ie-${box_name}.box"
}

download_prerequisites() {
    local base_url="https://download.virtualbox.org/virtualbox"
    local latest
    latest=$(curl -s "${base_url}/LATEST-STABLE.TXT")
    wget --quiet --continue \
        --output-document="scripts/VBoxGuestAdditions_${latest}.iso" \
        "${base_url}/${latest}/VBoxGuestAdditions_${latest}.iso"
    7z x "scripts/VBoxGuestAdditions_${latest}.iso" -y \
        -o"scripts/VBoxGuestAdditions"
    rm -f "scripts/VBoxGuestAdditions_${latest}.iso"

    wget --quiet --continue \
        --output-document=scripts/Win7-KB3191566-x86.zip \
        "https://go.microsoft.com/fwlink/?linkid=839522"
    7z x "scripts/Win7-KB3191566-x86.zip" -y \
        -o"$(pwd)/scripts/Win7-KB3191566-x86"
    rm -f "scripts/Win7-KB3191566-x86.zip"
}
