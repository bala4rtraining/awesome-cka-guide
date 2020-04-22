#!/bin/bash
#

set -e

. lib.sh

build() {

  local certdb=$1
  local certname=$2
  local package=$3
  local pkgsuffix=$4
  extras="$5"

  rpmbuild \
    --define "$pkgsuffix" \
    --define "certdb $certdb" \
    --define "certname $certname" \
    --define "debug_package %{nil}" \
    $extras \
      -bb rpmbuild/SPECS/$package.spec
}

build_patch() {

  cp keys/uefi_db.cer rpmbuild/SOURCES/visa.crt
  patch -N -p1 -d rpmbuild < kernel.patch
  patch -N -p1 -d rpmbuild < grub2.patch
  patch -N -p1 -d rpmbuild < shim.patch
  patch -N -p1 -d rpmbuild < shim-signed.patch
}

add_shim_artifacts_as_sources_to_signed_shim() {

  rpm2cpio rpmbuild/RPMS/x86_64/shim-unsigned-{{shim_ver}}.visa.x86_64.rpm | cpio --no-absolute-filenames -idm ./usr/share/shim/x64-{{shim_ver}}.visa/{shim,MokManager,fallback}.efi
  mv ./usr/share/shim/x64-{{shim_ver}}.visa/shim.efi rpmbuild/SOURCES/shimx64.efi
  mv ./usr/share/shim/x64-{{shim_ver}}.visa/*.efi    rpmbuild/SOURCES/
  rmdir -p usr/share/shim/x64-{{shim_ver}}.visa
}

build_kernel() {

  build $certdb $certname kernel       'buildid .visa' "--define dist.el7 --with baseonly --with=firmware --without debuginfo --without debug --without perf --target=$(uname -m) --clean"
}

build_grub() {

  build $certdb $certname grub2        'dist .el7.centos.visa' '--without debuginfo --clean'
}

build_shim () {

  build $certdb $certname shim         'dist .centos.visa' '--without debuginfo --clean'

  add_shim_artifacts_as_sources_to_signed_shim

  build $certdb $certname shim-signed  'dist .el7.visa' '--without debuginfo --clean'
}

build_visa_grub_and_initrd() {

#  . lib.sh
#  prepare_cert

  trap 'rm -rf usr myrpm lib boot' RETURN

  mkdir -p myrpm/boot/efi/EFI/visa

  rpm2cpio rpmbuild/RPMS/x86_64/grub2-efi-modules-{{visa_grub_ver}}.x86_64.rpm |cpio -idmu
  grub2-mkimage \
    --pubkey keys/grub_gpg.pub \
    -c grub.cfg.embedded.standalone \
    -O x86_64-efi \
    -o .visa-grubx64.efi.unsigned \
    -p /EFI/visa \
    -d ./usr/lib/grub/x86_64-efi/ \
    all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gfxmenu \
    gfxterm gzio halt hfsplus iso9660 jpeg loadenv lvm mdraid09 mdraid1x minicmd normal \
    part_apple part_msdos part_gpt password_pbkdf2 png reboot search search_fs_uuid search_fs_file \
    search_label sleep syslinuxcfg test tftp regexp video xfs linuxefi verify gcry_dsa gcry_sha256

  pesign -n $certdb -c $certname -s -i .visa-grubx64.efi.unsigned --force -o myrpm/boot/efi/EFI/visa/grub.efi

  cp visa-grub.cfg myrpm/boot/efi/EFI/visa/grub.cfg
  grub_sign myrpm/boot/efi/EFI/visa/grub.cfg

  rpmbuild --define "my_dir $PWD" -bb rpmbuild/SPECS/visa-grub.spec

  rm -f myrpm/boot/efi/EFI/visa/{grub.efi,grub.cfg{,.sig}}

  rpm2cpio rpmbuild/RPMS/x86_64/kernel-{{kernel_ver}}.visa.x86_64.rpm |
    cpio -idm ./lib/modules/\* ./boot/System.map-\* ./boot/vmlinuz-3.10.0-327.3.1.el7.visa.x86_64

  depmod -ae -b . -F boot/System.map-{{kernel_ver}}.visa.x86_64 {{kernel_ver}}.visa.x86_64

  grub_sign boot/vmlinuz-{{kernel_ver}}.visa.x86_64
  mv boot/vmlinuz-{{kernel_ver}}.visa.x86_64.sig myrpm/boot

  echo """menuentry 'Visa Signed CentOS Linux {{kernel_ver}}' --unrestricted {

  set gfxpayload=keep

  search --no-floppy --set=root --label boot

  linuxefi  /vmlinuz-{{kernel_ver}}.visa.x86_64 root=LABEL=root cirrus.modeset=0 ro rhgb quiet LANG=en_US.UTF-8
  initrdefi /visa-initramfs-{{kernel_ver}}.visa.x86_64.img

}""" > myrpm/boot/efi/EFI/visa/grub.cfg-{{kernel_ver}}.visa.x86_64
  grub_sign myrpm/boot/efi/EFI/visa/grub.cfg-{{kernel_ver}}.visa.x86_64

  umask 0022

  ( echo hp hpsa ixgbe tg3 mgag200
    echo virtio virtio_blk virtio_net virtio_ring
  ) |
  while read hw_type modules; do

    dracut \
      --kver {{kernel_ver}}.visa.x86_64 \
      --kmoddir $PWD/lib/modules/{{kernel_ver}}.visa.x86_64 \
      --omit="fcoe lvm dm ca-cert-override" \
      --filesystems="ext4 vfat xfs" \
      --fscks="fsck.vfat fsck.ext4 e2fsck" \
      --omit-drivers="cirrus xfs" \
      --add-drivers="loop bochs-drm zram $modules" \
      --force \
      myrpm/boot/visa-initramfs-{{kernel_ver}}.visa.x86_64.img {{kernel_ver}}.visa.x86_64

    chmod +rwx myrpm/boot/visa-initramfs-{{kernel_ver}}.visa.x86_64.img
    grub_sign myrpm/boot/visa-initramfs-{{kernel_ver}}.visa.x86_64.img

    rpmbuild --define "hw_type $hw_type" --define "my_dir $PWD" -bb rpmbuild/SPECS/visa-initrd.spec
  done
}


TARGETS="$@"

prepare_cert

for target in $TARGETS; do

  build_$target
done
