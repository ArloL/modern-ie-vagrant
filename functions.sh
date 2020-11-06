#!/usr/bin/env bash

set -o errexit
set -o nounset

run_command() {
    send_keys 1 "<winPress>" r "<winRelease>"
    sleep 13
    send_keys 1 "${1}" "<enter>"
}

vm_id() {
    if [ -f ".vagrant/machines/${BOX_NAME}/virtualbox/id" ]; then
        cat ".vagrant/machines/${BOX_NAME}/virtualbox/id"
    else
        echo ""
    fi
}

vm_import() {
    if ! vm_snapshot_exists "Pre-Boot"; then
        download_box "${BOX_NAME}"
        download_prerequisites "${BOX_NAME}"
        vagrant destroy "${BOX_NAME}" --force
        boot_timeout=1 vagrant up "${BOX_NAME}" || true
        vagrant halt "${BOX_NAME}" --force
        VM=$(vm_id)
    fi
}

vm_up() {
    VMState=$(vm_info "VMState=" 2)
    if [ "${VMState}" = "saved" ]; then
        boot_timeout=15 vagrant up "${BOX_NAME}" || true
        vm_storage_attach
    else
        vm_storage_attach
        boot_timeout=15 vagrant up "${BOX_NAME}" || true
    fi
}

vm_halt() {
    vagrant halt "${BOX_NAME}" --force
    vm_storage_detach_and_close
}

vm_storage_detach_and_close() {
    disk_path=$(vm_info '^"IDE Controller-0-1"=' 4)
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium "emptydrive"
    if [ "${disk_path}" != "emptydrive" ]; then
        VBoxManage closemedium dvd "${disk_path}" --delete || true
        rm -f "${disk_path}" || true
    fi
}

vm_storage_attach() {
    vm_storage_detach_and_close
    scriptIso="scripts-${BOX_NAME}-$(date -u +"%Y%m%dT%H%M%S").iso"
    hdiutil makehybrid -iso -joliet -o "${scriptIso}" scripts
    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium "${scriptIso}"
    if [ "$(vm_info "VMState=" 2)" = "running" ]; then
        vm_close_dialogs 15
    fi
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
    if [ "${2:-}" != "" ] && vm_snapshot_exists "${2}"; then
        return 0
    fi
    if [ "${3:-}" != "" ] && vm_snapshot_exists "${3}"; then
        return 0
    fi
    vm_storage_detach_and_close
    vagrant snapshot restore "${BOX_NAME}" "${1}" --no-start
    VBoxManage modifyvm "${VM}" \
        --recordingfile \
        "recordings/${BOX_NAME}-$(date -u +"%Y%m%dT%H%M%S").webm"
    if [ "${1}" = "Pre-Boot" ]; then
        reset_storage_controller
        vm_network_connection 1 off
    fi
}

vm_snapshot_restore_and_up() {
    if [ "${2:-}" != "" ] && vm_snapshot_exists "${2}"; then
        return 0
    fi
    if [ "${3:-}" != "" ] && vm_snapshot_exists "${3}"; then
        return 0
    fi
    vm_snapshot_restore "${1}"
    vm_up
}

vm_snapshot_save() {
    vm_storage_detach_and_close
    vagrant snapshot save "${BOX_NAME}" "${1}"
    vm_storage_attach
}

vm_snapshot_delete_all() {
    mapfile -t snapshots < <(VBoxManage snapshot "${VM}" list --machinereadable | grep '^SnapshotName' | awk -F '"' '{ print $2 }')
    for snapshot in "${snapshots[@]}"; do
        if [ "${snapshot}" != "Pre-Boot" ]; then
            VBoxManage snapshot "${VM}" delete "${snapshot}"
        fi
    done
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

vm_reset() {
    vm_network_connection 1 on

    VBoxManage storageattach "${VM}" \
        --storagectl "IDE Controller" \
        --port 0 --device 1 --type dvddrive --medium emptydrive

    VBoxManage setextradata "${VM}" "GUI/Fullscreen"
    VBoxManage setextradata "${VM}" "GUI/LastCloseAction"
    VBoxManage setextradata "${VM}" "GUI/LastGuestSizeHint"
    VBoxManage setextradata "${VM}" "GUI/LastNormalWindowPosition"
    VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeDevicesMenuActions"
    VBoxManage setextradata "${VM}" "GUI/RestrictedRuntimeMachineMenuActions"
    VBoxManage setextradata "${VM}" "GUI/ScaleFactor"
    VBoxManage setextradata "${VM}" "GUI/StatusBar/IndicatorOrder"
}

vm_package() {
    VBoxManage modifyvm "${VM}" --recording off
    vm_reset
    vagrant package "${BOX_NAME}" \
        --output "${BOX_NAME}.box" \
        --Vagrantfile Vagrantfile-package
    vagrant box add --name "okeeffe-${BOX_NAME}" --force "${BOX_NAME}.box"
    if [ "${VAGRANT_CLOUD_ACCESS_TOKEN}" != "" ] && [ "${VERSION}" != "undefined" ]; then

        base_url="https://app.vagrantup.com/api/v1/box/breeze/${BOX_NAME}"

        # create version
        curl --silent --fail \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
            "${base_url}/versions" \
            --data '
                { "version": {
                    "version": "'"${VERSION}"'",
                    "description": ""
                } }' > /dev/null

        # create provider
        curl --silent --fail \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
            "${base_url}/version/${VERSION}/providers" \
            --data '{ "provider": { "name": "virtualbox" } }' > /dev/null

        # prepare upload and get upload path
        response=$(curl --silent --fail \
            --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
            "${base_url}/version/${VERSION}/provider/virtualbox/upload")

        upload_path=$(echo "$response" | jq -r .upload_path)

        # perform the upload
        curl --silent --fail \
            --request PUT \
            --upload-file "${BOX_NAME}.box" "${upload_path}"

        # release the version
        curl --silent --fail \
            --request PUT \
            --header "Authorization: Bearer ${VAGRANT_CLOUD_ACCESS_TOKEN}" \
            "${base_url}/version/${VERSION}/release"

    fi
    rm -f "${BOX_NAME}.box"
}

vm_info() {
    VBoxManage showvminfo "${VM}" --machinereadable | grep "${1}" | awk -F '"' '{ print $'"${2}"' }'
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
        echo "Waiting for ${VM} to be in VMState poweroff."
        VMState=$(vm_info "VMState=" 2)
        if [ "${VMState}" = "poweroff" ]; then
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
    VBoxManage modifyvm "${VM}" --cableconnected"${1}" "${2}"
}

vm_run_elevate() {
    case ${BOX_NAME} in
        win7*) run_command "e:\\elevate.bat e:\\ ${1}";;
        win*) run_command "d:\\elevate.bat d:\\ ${1}";;
    esac
    sleep 110
    # select Yes on UAC
    send_keys 1 "<left>" "<enter>"
}

vm_run_guest_additions_install() {
    case ${BOX_NAME} in
    win7*)
        run_command 'cmd /c "e:\vboxwindowsadditions /S && shutdown /s /t 0 /f"'
        sleep 111
        # select Yes on UAC
        send_keys 1 "<left>" "<enter>"
        sleep 30
        # ensure focus on driver window
        send_keys 1 "<winPress>" "<down>" "<winRelease>"
        sleep 13
        # select always trust and Yes to add driver
        send_keys 1 "<left>" "<left>" "<space>" "<right>" "<enter>"
        ;;
    win81*)
        run_command 'cmd /c "d:\vboxwindowsadditions /S && shutdown /s /t 0 /f"'
        sleep 111
        # select Yes on UAC
        send_keys 1 "<left>" "<enter>"
        sleep 30
        # ensure focus on driver window
        send_keys 1 "<winPress>" "<down>" "<winRelease>"
        sleep 13
        # select Yes to add driver
        send_keys 1 "<left>" "<enter>"
        ;;
    win10*)
        run_command 'cmd /c "d:\vboxwindowsadditions /S && shutdown /s /t 0 /f"'
        sleep 111
        # select Yes on UAC
        send_keys 1 "<left>" "<enter>"
        sleep 30
        # ensure focus on driver window
        send_keys 1 "<winPress>" "<down>" "<winRelease>"
        sleep 13
        # select Yes to add driver
        send_keys 1 "<left>" "<enter>"
        ;;
    esac
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
    case ${1} in
    "win7-ie8")
        download "win7-ie8" "IE8 - Win7.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE8/IE8.Win7.Vagrant.zip";;
    "win7-ie9")
        download "win7-ie9" "IE9 - Win7.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE9/IE9.Win7.Vagrant.zip";;
    "win7-ie10")
        download "win7-ie10" "IE10 - Win7.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE10/IE10.Win7.Vagrant.zip";;
    "win7-ie11")
        download "win7-ie11" "IE11 - Win7.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip";;
    "win81-ie11")
        download "win81-ie11" "IE11 - Win81.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win81.Vagrant.zip";;
    "win10-edge")
        download "win10-edge" "MSEdge - Win10.box" \
            "https://az792536.vo.msecnd.net/vms/VMBuild_20190311/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip";;
    *)
        echo "Sorry, I can not get a VM for you!"
        exit 1;;
    esac
}

download() {
    local name=${1}
    local boxName=${2}
    local url=${3}
    pushd vms
    boxListSearch=$(vagrant box list | grep "modern.ie/${name}" || true)
    if [ ! "${boxListSearch}" = "" ]
    then
        echo "${name} exists"
        return
    fi
    if [ -f "modern.ie-${name}.box" ]
    then
        shasum --check "modern.ie-${name}.box.sha1"
        vagrant box add --name="modern.ie/${name}" --force "modern.ie-${name}.box"
        rm -f "modern.ie-${name}.box"
        return
    fi
    if ! shasum --check "modern.ie-${name}.zip.sha1"
    then
        rm -f "modern.ie-${name}.zip"
        wget --quiet  --continue --output-document="modern.ie-${name}.zip" "${url}"
        shasum --check "modern.ie-${name}.zip.sha1"
    fi
    if [ ! -f "${boxName}" ]
    then
        unzip "modern.ie-${name}.zip"
    fi
    mv "${boxName}" "modern.ie-${name}.box"
    shasum --check "modern.ie-${name}.box.sha1"
    rm -f "modern.ie-${name}.zip"
    vagrant box add --name="modern.ie/${name}" --force "modern.ie-${name}.box"
    rm -f "modern.ie-${name}.box"
    popd
}

download_prerequisites() {
    pushd scripts
    latest=$(curl -s https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)
    wget --quiet --continue --timestamping "https://download.virtualbox.org/virtualbox/${latest}/VBoxGuestAdditions_${latest}.iso"
    7z x "VBoxGuestAdditions_${latest}.iso" -y -o"$(pwd)/VBoxGuestAdditions"
    case ${1:-} in
        "win7"*)
            ;&
        "")
            wget --quiet --continue --timestamping --output-document=Win7-KB3191566-x86.zip \
                "https://go.microsoft.com/fwlink/?linkid=839522"
            7z x "Win7-KB3191566-x86.zip" -y -o"$(pwd)/Win7-KB3191566-x86"
            ;;
    esac
    popd
}
