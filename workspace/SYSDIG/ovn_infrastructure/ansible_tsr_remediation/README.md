# TSR Remediation Playbooks

Included in this project are playbooks that will address TSR findings against OVN.

Remediation should be written as sub-playbook under the ```remediation``` sub-directory and all of them should be included in ```main.yml```.

## List of tasks
### tsr_4974_4975
RHEL 7 TSR - 10.10 & 10.11 - Find Un-owned Files and Directories

### tsr_4977
RHEL 7 TSR 10.12 - Find system executables with SUID (Remove SUDO package)

### tsr_4979
RHEL 7 TSR 10.13 - Find system executables with SGID (Remove ssmtp package)

### tsr_8886
add default group as 0 to root

### tsr_5137
modifies user home directories permissions not writeable to groups and others.

### tsr_5116
modifies user id to be greater than 500 for service accounts dhcpd and haproxy. It assumes all processes running under these accounts have exited.

### tsr_8873
Enable auditing for processes that start prior to audit

### tsr_8864  
Linux RHEL 7 TSR - 1.7.10 Remove HTTP Server

### tsr_6742
Linux RHEL 7 TSR - 7.2.8 Disable SSH Root Login -  Disables the capability for root user to login remotely by setting "PermitRootLogin no".

### tsr_6834_6835_6836_6837_6838_6839_6840_6841_6842_6843
TSR remediation for password creation requirement using pam_cracklib module. The pam_cracklib module must be configured to enforce passwords of at least 7 characters in length, alphanumeric passwords combining punctuation or numbers with regular letters, and 6 tries before sending back a failure

| TSR Policy ID | Description                                                                                              |
| ------------- | -------------------------------------------------------------------------------------------------------- |
| `6834`        | Set `retry=6` parameter for pam_cracklib module to enfore 6 password retry attempts                      |
| `6835`        | Set `minclass=0` parameter for pam_cracklib module to set min number of character classes                |
| `6836`        | Set `minlen=7` parameter for pam_cracklib module to set min length for new password                      |
| `6837`        | Set `lcredit=-1` parameter for pam_cracklib module to set lower-case characters credit for new password  |
| `6838`        | Set `ucredit=-1` parameter for pam_cracklib module to set upper-case characters credit for new password  |
| `6839`        | Set `dcredit=-1` parameter for pam_cracklib module to set digits credit for new password                 |
| `6840`        | Set `ocredit=-1` parameter for pam_cracklib module to set other characters credit for new password       |
| `6841`        | Set `maxrepeat=0` parameter for pam_cracklib module to disable consecutive character check               |
| `6842`        | Set auth parameters for pam_faillock module                                                              |
| `6843`        | Set `remember=12` parameter for pam_unix module to set recent password history before they can be reused |

### tsr_7583
This will lock inactive user accounts after 90 days
editing /etc/default/useradd file to have INACTIVE=90

### tsr_8858
This will set sticky bit to directories 
RESTRICTED DELETION FLAG OR STICKY BIT
The restricted deletion flag or sticky bit is a single bit, whose interpretation depends on the file type. For directories, it prevents unprivileged users from removing or renaming a file in the directory unless they own the file or the directory; this is called the restricted deletion flag for the directory, and is commonly found on world-writable directories like /tmp. For regular files on some older systems, the bit saves the program's text image on the swap device so it will load more quickly when run; this is called the sticky bit
### tsr_8872
Create and set permissions on rsyslog log files to 600
### tsr_8869
This will remove the world writable file permissions 
### tsr_4829
This will remove telnet package 
### tsr_6715
This will set default ClientAliveInterval 900 and ClientAliveCountMax 0 in /etc/ssh/sshd_config
## Changelog
