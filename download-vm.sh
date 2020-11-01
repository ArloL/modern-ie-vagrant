#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

download() {
    local name=${1}
    local boxName=${2}
    local url=${3}
    trap 'popd' EXIT
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
}

case ${1} in
   "win7-ie8") download "win7-ie8" "IE8 - Win7.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE8/IE8.Win7.Vagrant.zip";;
   "win7-ie9") download "win7-ie9" "IE9 - Win7.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE9/IE9.Win7.Vagrant.zip";;
   "win7-ie10") download "win7-ie10" "IE10 - Win7.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE10/IE10.Win7.Vagrant.zip";;
   "win7-ie11") download "win7-ie11" "IE11 - Win7.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip";;
   "win81-ie11") download "win81-ie11" "IE11 - Win81.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win81.Vagrant.zip";;
   "win10-edge") download "win10-edge" "MSEdge - Win10.box" "https://az792536.vo.msecnd.net/vms/VMBuild_20190311/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip";;
   *) echo "Sorry, I can not get a VM for you!";;
esac
