#!/bin/bash
#
# scp de_sb.* HOST:; ssh HOST ./de_sb.sh

tar xzf /de_sb.tgz

# >zPK.esl
# LD_LIBRARY_PATH=. usr/bin/sign-efi-sig-list -k keys/uefi_PK.key -c keys/uefi_PK.crt PK zPK.esl zPK.auth

LD_LIBRARY_PATH=. ./usr/bin/efi-updatevar -f zPK.auth PK

rm -f de_sb.* usr/bin/sign-efi-sig-list ./usr/bin/efi-updatevar zPK.auth libcrypto.so.1.0.0
rmdir -p usr/bin

efibootmgr | grep "Visa Signed" | sed 's/Boot\([0-9][0-9][0-9A-F][0-9A-F]\).*/\1/' | xargs -r -n 1 efibootmgr -B -b

rm /boot/vmlinuz-3.10.0-327.3.1.el7.visa.x86_64.sig

grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
