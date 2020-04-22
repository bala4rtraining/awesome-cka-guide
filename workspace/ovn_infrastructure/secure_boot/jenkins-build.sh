#!/bin/bash
#

set -e

BOX=centos-7.2-1
export VAGRANT_DEFAULT_PROVIDER=libvirt

artifactory_dl() {

  [ -f files/$1 ] ||
    curl -s -f -o files/$1 https://sl55ovnapq01.visa.com/git/@pod1/3rd_party/secure_boot/v1:/$1
}

download_3rd_party_binaries() {

  artifactory_dl CentOS-7-x86_64-Minimal-1511.iso
  artifactory_dl efitools-1.5.3-1.1.x86_64.rpm
}

build_vagrant_box() {

  vagrant box list | grep -qs $BOX || (

    cd packer-templates/centos-7.2

    PACKER_LOG=1
    CHECKPOINT_DISABLE=1

    packerio build --only=qemu -var iso_dir=../../files template.json

    vagrant box add --name $BOX packer_qemu_libvirt.box

    rm packer_qemu_libvirt.box
  )
}

provision_build_environment() {

  vagrant destroy build
  vagrant up build
}

upload_keys() {

  vagrant ssh-config build > .vagrant-ssh-config
  scp -F .vagrant-ssh-config -r keys/ build:
}

build_signed_images() {

  vagrant ssh build -c "KEY_PASS=pass bash \
    build.sh \
      patch \
      kernel \
      grub \
      visa_grub_and_initrd"

  vagrant ssh build -c "sudo KEY_PASS=pass bash \
    pack.sh \
      centos_repo \
      visa_repo \
      centos_liveos \
      kickstart \
      efi"

}

download_artifacts() {

  rsync -av -e "ssh -F .vagrant-ssh-config" build:*.tar.gz files/
}

destroy_build_environment() {

  vagrant destroy build
}

#upload_blob() {
#
#  source /dev/stdin <<<"`curl -s -f https://sl55ovnapq01.visa.com/git/@pod1/api/v0.5:/ovngit-lib.sh`"
#
#  BRANCH=$(date +visa_secure_boot/%Y/%m-%d/$BUILD_NUMBER)
#
#  MESSAGE="""\
#Build-tag: $BUILD_TAG
#Build-ref: $(git log -n1 --pretty=format:%H%d)"""
#
#  cd files
#  ovngit_upload "$BRANCH" "$MESSAGE" {centos_liveos,centos_repo,visa_repo,kickstart,efi}.tar.gz
#}

download_3rd_party_binaries

build_vagrant_box

provision_build_environment

upload_keys

build_signed_images

download_artifacts

destroy_build_environment

#upload_blob
