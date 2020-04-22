#!/bin/bash
#

set -e

do_visa_repo() {

  echo "*** Creating Visa repo"

  rm -rf out/http/repo/visa/{repodata,Packages}
  mkdir -p out/http/repo/visa/Packages

  cp rpmbuild/RPMS/x86_64/*.rpm out/http/repo/visa/Packages

  ( cd out/http/repo/visa; createrepo --database . -o .; )

  echo "*** Packaging Visa repo"

  tar czf visa_repo.tar.gz -C out/http/repo/visa .
}

do_kickstart() {

  rm -rf out/http/ks
  mkdir -p out/http/ks
  cp min-ks.cfg out/http/ks
  tar czf kickstart.tar.gz -C out/http ks
}

do_centos_repo() {

  echo "*** Packaging CentOS repo"
  mount -r CentOS-7-x86_64-Minimal-1511.iso /mnt
  tar czf centos_repo.tar.gz -C /mnt/ Packages repodata
  umount /mnt
}

do_centos_liveos() {

  trap 'rm -rf squashfs-root LiveOS; umount /mnt || true 2> /dev/null' RETURN

  mount -r CentOS-7-x86_64-Minimal-1511.iso /mnt

  echo "*** Patching LiveOS * Unpacking LiveOS image"

  rm -rf squashfs-root
  unsquashfs /mnt/LiveOS/squashfs.img
  mount squashfs-root/LiveOS/rootfs.img /mnt

  echo "*** Patching LiveOS * Substitute kernel modules"

  find /mnt/ -name \*{{orig_kernel_ver}}.x86_64\*|xargs -r rename {{orig_kernel_ver}}.x86_64 {{kernel_ver}}.visa.x86_64

  rpm2cpio rpmbuild/RPMS/x86_64/kernel-{{kernel_ver}}.visa.x86_64.rpm |
  ( cd /mnt;
    cpio -im $(find /mnt/lib/modules/{{kernel_ver}}.visa.x86_64 -name \*.ko|sed s,/mnt,.,);
  )

  echo "*** Patching LiveOS * Adding SB certificates and EFI tools"

  mkdir /mnt/visa
  rpm2cpio efitools-1.5.3-1.1.x86_64.rpm | cpio -i --to-stdout ./usr/bin/efi-updatevar > /mnt/visa/efi-updatevar
  rpm2cpio efitools-1.5.3-1.1.x86_64.rpm | cpio -i --to-stdout ./usr/bin/efi-readvar > /mnt/visa/efi-readvar
  chmod +x /mnt/visa/efi-*var
  ln -sf libcrypto.so.1.0.1e /mnt/usr/lib64/libcrypto.so.1.0.0
  cp keys/uefi_*.esl keys/uefi_*.auth /mnt/visa

  echo "*** Patching LiveOS * Adding Visa golden laptop SSL certificate"

  cp -f keys/inst_https.crt /mnt/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem

  echo "*** Patching LiveOS * Omit unnecessary initramfs images"

  sed -i 's/\/boot\/vmlinuz-\*"/\/boot\/vmlinuz-*.x86_64"/' /mnt/usr/lib64/python2.7/site-packages/pyanaconda/packaging/__init__.py

  umount /mnt/

  echo "*** Patching LiveOS * Packing LiveOS image"

  mkdir -p LiveOS
  mksquashfs squashfs-root LiveOS/squashfs.img -comp xz -Xbcj x86 -noappend

  echo "*** Packaging Centos LiveOS"

  tar cf centos_liveos.tar -C /mnt/ --exclude squashfs.img --exclude=Packages --exclude=repodata .
  tar rf centos_liveos.tar LiveOS/squashfs.img
  gzip -9f centos_liveos.tar
  umount /mnt
}

override_pxe_grub() {

  . lib.sh
  prepare_cert

  trap 'rm -rf usr' RETURN

  rpm2cpio rpmbuild/RPMS/x86_64/grub2-efi-modules-{{visa_grub_ver}}.x86_64.rpm |cpio -idmu

  grub2-mkimage \
    --pubkey keys/grub_gpg.pub \
    -c grub.cfg.embedded \
    -O x86_64-efi \
    -o .grubx64.efi.unsigned \
    -p /uefi \
    -d ./usr/lib/grub/x86_64-efi/ \
    all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gfxmenu \
    gfxterm gzio halt hfsplus iso9660 jpeg loadenv lvm mdraid09 mdraid1x minicmd normal \
    part_apple part_msdos part_gpt password_pbkdf2 png reboot search search_fs_uuid search_fs_file \
    search_label sleep syslinuxcfg test tftp regexp video xfs linuxefi verify gcry_dsa gcry_sha256

  pesign -n $certdb -c $certname -s -i .grubx64.efi.unsigned --force -o out/tftp/uefi/grubx64.efi
}

extract_efi_binaries() {

  echo "*** Extracting EFI binaries"

  mkdir -p out/tftp/uefi

  rpm2cpio rpmbuild/RPMS/x86_64/kernel-{{kernel_ver}}.visa.x86_64.rpm |
  cpio -i --to-stdout ./boot/vmlinuz-{{kernel_ver}}.visa.x86_64 > out/tftp/uefi/vmlinuz

#  rpm2cpio rpmbuild/RPMS/x86_64/shim-{{shim_signed_ver}}.visa.x86_64.rpm |
#  cpio -i --to-stdout ./boot/efi/EFI/centos/shim.efi > out/tftp/uefi/shim.efi

  rpm2cpio rpmbuild/RPMS/x86_64/grub2-efi-{{visa_grub_ver}}.x86_64.rpm |
  cpio -i --to-stdout ./boot/efi/EFI/centos/grubx64.efi > out/tftp/uefi/grubx64.efi
}

create_pxe_initrd() {

  echo "*** Creating PXE initrd"

  #mpathconf --enable
  rm -rf lib
  rpm2cpio rpmbuild/RPMS/x86_64/kernel-{{kernel_ver}}.visa.x86_64.rpm |
    cpio -idm ./lib/modules/\* ./boot/System.map-\*

  depmod -ae -b . -F boot/System.map-{{kernel_ver}}.visa.x86_64 {{kernel_ver}}.visa.x86_64

  mount -r CentOS-7-x86_64-Minimal-1511.iso /mnt
  modules="$(lsinitrd -f usr/lib/dracut/modules.txt /mnt/images/pxeboot/initrd.img | xargs)"
  umount /mnt

  touch /.buildstamp

  dracut \
    -N \
    --kver {{kernel_ver}}.visa.x86_64 \
    --kmoddir ./lib/modules/{{kernel_ver}}.visa.x86_64 \
    --nomdadmconf \
    --nolvmconf \
    --xz \
    --install '/.buildstamp' \
    --no-early-microcode \
    -a "$modules ca-cert-override" \
    --force \
    out/tftp/uefi/initrd.img {{kernel_ver}}.visa.x86_64

  chmod +r out/tftp/uefi/initrd.img

  rm -rf lib boot
}

do_efi() {

  . lib.sh

  extract_efi_binaries
  create_pxe_initrd
  override_pxe_grub
  cp grub.cfg out/tftp/uefi
  grub_sign out/tftp/uefi/initrd.img
  grub_sign out/tftp/uefi/vmlinuz
  grub_sign out/tftp/uefi/grub.cfg

  echo "*** Packaging artifacts"

  tar czf efi.tar.gz -C out/tftp/uefi .
}

TARGETS="$@"

for target in $TARGETS; do

  do_$target
done
