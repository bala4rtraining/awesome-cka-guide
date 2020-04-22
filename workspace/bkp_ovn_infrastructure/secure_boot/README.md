# Secure boot README

## Introduction

Secure boot is UEFI feature which provides a mechanism to ensure that machine boots using only trusted software (platform firmware and operating system). This is achieved by verifying cryptographic signature of each subsequent element of boot process before executing/evaluating it.

## Visa owned 

Using Secure boot mechanism a machine can be put into state where it can only boot software signed by Visa. That includes OS installers, such as RedHat Anaconda.

## What this package is

Outcome of execution of this suite is

1. Visa signed CentOS kernel, GRUB2 bootloader and shim.
2. PXE boot installation source, which
* is Visa signed 
* installs Visa signed images to target machine

The latter is essentially a zero touch provisioning of Visa owned machines. 

At the moment this functionality is only validated on QEMU emulator, to extend it to physical machines small changes are still needed.   

## How to run it

* Vagrant is needed on the build host
* `artifactory` should be accessible from the build host

> jenkins-build.sh

After successful build completion, all the artifacts will automatically be uploaded from `files/` subdirectory to `artifactory`

## Chain of trust

| Element | Chain of trust | Comment | 
|---------|----------------|---------|
| Firmware | **[SB cert]** | Verified directly by Secure boot |
| GRUB2 bootloader | **[SB cert]** | Verified directly by Secure boot |
| GRUB2 commandline | [SB cert] `->` **[hash]** | Is password protected, password hash is embedded into GRUB2 image, which is verified directly by Secure boot |
| GRUB2 configuration | [SB cert] `->` **[GPG]** | Signed by private GPG key, public key is embedded into GRUB2 image, which is verified directly by Secure boot |
| Linux kernel | **[SB cert]** | Verified directly by Secure boot |
| Linux kernel | [SB cert] `->` **[GPG]**  | Additionally signed by private GPG key, public key is embedded into GRUB2 image, which is verified directly by Secure boot |
| Initial ramdisk | [SB cert] `->` **[GPG]**  | Signed by private GPG key, public key is embedded into GRUB2 image, which is verified directly by Secure boot |

## Input keys

Following keys/certificates are an input to the build process

| Name     | Description |
|----------|-------------|
| uefi_db  | The certificate binary images will be verified against by secure boot |
| uefi_KEK | UEFI key exchange key, used to sign updates to `uefi_db` |
| uefi_PK  | UEFI platform key, used to sign updates to `uefi_KEK`, and to turn Secure boot mode on/off |
| grub_gpg | GPG key used to sign/verify all files loaded by GRUB2 bootloader |

Sample procedure that demonstrates how to generate all these keys is provided in `make_keys.sh` 

## Output artifacts

| Artifact | Description | Destination on Golden Laptop |
|----------|-------------|------------------------------|
| visa_repo.tar.gz | Signed Visa binaries: kernel, GRUB2, shim | /var/www/html/repo/visa |
| centos_repo.tar.gz | Unchanged CentOS repository taken off CentOS DVD | /var/www/html/repo/centos |
| kickstart.tar.gz | Anaconda kickstart configuration | /var/www/html/ks |
| efi.tar.gz | UEFI PXE installation files | /var/lib/tftp |
| centos_liveos.tar.gz | CentOS Anaconda with Visa signed kernel modules and Visa HTTPS certificate | /var/www/html/repo/centos |

## Repeatable build

This procedure is designed to produce repeatable build with following exceptions

* derived files timestamps
* random (unique) linux kernel key used to sign modules 

Inputs that directly influence build result

* keys provided in `keys` directory
* in/out RPM package versions listed in `group_vars/all`
* pbkdf2 GRUB2 command line password hash in `group_vars/all`
* Centos DVD image sourced from `artifactory`
* CentOS repository snapshot hosted on sl55ovnapq01

## IP addresses

As DNS infrastructure for target environment isn't ready yet, the pipeline relies on hardcoded IP addresses present in the environment. Once DNS work is complete, IP addresses need to be updated with corresponding names. This includes HTTPS certificate's CN.

