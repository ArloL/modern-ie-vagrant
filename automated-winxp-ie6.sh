#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

wait_for_guestcontrol() {
    GuestAdditionsRunLevel=0
    while true ; do
        echo "Waiting for ${1} to be available for guestcontrol."
        eval "$(VBoxManage showvminfo "${1}" --machinereadable | grep 'GuestAdditionsRunLevel')"
        if [ "${GuestAdditionsRunLevel}" -eq "3" ]; then
            return 0;
        fi
        sleep 5
    done
}

wait_for_virtualbox_id() {
    while true ; do
        if [ -f .vagrant/machines/default/virtualbox/id ]; then
            return 0;
        fi
        sleep 5
    done
}

export box_name=winxp-ie6
export boot_timeout=5

vagrant up || true

wait_for_virtualbox_id

VM=$(cat .vagrant/machines/default/virtualbox/id)

VMState=''
eval "$(VBoxManage showvminfo "${VM}" --machinereadable | grep 'VMState')"
if [ "${VMState}" != 'running' ]; then
    echo "The virtual machine ${VM} is not running."
    exit 1;
fi

wait_for_guestcontrol "${VM}"

sleep 60

VBoxManage guestcontrol "${VM}" --verbose --username IEUser --password "Passw0rd!" run --exe "//VBOXSRV/vagrant/provision-${box_name}.bat"

export boot_timeout=1200

vagrant reload

vagrant provision

vagrant package --output "okeeffe-${box_name}.box" --Vagrantfile Vagrantfile-package
