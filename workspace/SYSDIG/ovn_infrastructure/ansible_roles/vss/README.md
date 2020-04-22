# VSS Deployment
## About
VSS is a component within our settilement system. It takes in INPAs from MVS, process it to generate a report. It also takes in snapshot inbetween jobs to HDFS. For more info, please see [https://visawiki.trusted.visa.com/display/OVN/VSS+Wrapper](https://visawiki.trusted.visa.com/display/OVN/VSS+Wrapper).

## Dependencies
For VSS to work properly we need the following components deployed in the cluster:
- Hadoop cluster
- Riak
- Nomad cluster (servers and VSS-enabled client)

## Roles
### deploy.yml
This role will do the following:
1. Install VSS binaries.
2. Install VSS wrapper.
3. Submit the VSS nomad jobs. Currently there are 3 jobs:
    - configInitNomad.nomad
    - configRunNomad.nomad
    - runVSSWrapper.sh
4. Injects hostname, ports, username and password to VSS shell scripts.

### clean_deploy.yml
Same like deploy.yml but it will delete the existing intermediary files in the server, and use the ones from the rpm package.

### sshkeys.yml
Creates private keys for the VSS server and copies the public key to the FTPS server.

### setup_connection_test.yml
Creates mock files which later will be used by the connection_test.yml task.

### connection_test.yml
Test SSH and FTP connectiviy between VSS server, FTPS server and the designated MVS.

### intermediary_sync.yml
Copies intermediary files from the FTPS server into the VSS server.

## Variables
- **vss_hostname** - Hostname of the server where VSS gets deployed
- **ssh**
    - **username** - Username that will be used to SSH into FTPS server (default: "was")
    - **port** - SSH port of the FTPS server (default: 22)
    - **private_key_path** - Private key of the identity used to SSH into FTP server
    - **hostname** - Hostname of the FTPS server
- **sftp**
    - **directory** - The directory in the remote FTPS server where VSS Wrapper should download INPA and config files from. Usually it'll look like this: ```/var/vsftpd/<ftps-username>```. FTPS username might vary in different environment.
    - **polling_interval** - Interval of VSS server polling for new input files on the FTPS server. Measured in seconds.
    - **inpa_marker_file** - The name of the file that we should check inside the ```vss_sftp_directory```, to make sure that the INPA drop-off has been completed by MVS. Defaults to ```endoftransfer.txt```.
- **hdfs**
    - **namenodes** (string list: "hostname:port") - List of hostname or IP including port of the HDFS cluster namenodes
    - **directory** - VSS directory inside HDFS (default: "/vss")
- **local**
    - **input_dir** - VSS input directory (default: "/opt/app/vss/input")
    - **intermediary_dir** - VSS intermediary file directory (default: "/opt/app/vss/files")
    - **output_dir** - VSS output directory
- **riak**
    - **nodes** (string list: "hostname:port") - List of Riak hostnames or IP + their ports
    - **max_connections** - Max connections allowed for the Riak client (default: 100)
    - **bucket_type** - Bucket type for VSS (default: "vss")
- **vss_daily_exec_path** - Path to the shell script that will be run during the report generation phase. Ideally this should point to VSS wrapper runner shell script.
- **vss_inpa_marker_file** - 
- **vss_inpa_flag_path** - The name of the file that the VSS shell script creates after it finishes processing the configuration file. VSS Wrapper will check the existence of this file before it can proceed with the report generation. Defaults to ```{{ vss_binaries_path }}/inpaRun.sh```.
