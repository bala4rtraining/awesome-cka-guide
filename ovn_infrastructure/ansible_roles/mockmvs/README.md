MockMVS
===
About
---

MockMVS is a service whose purpose is to mock MVS. It runs as a FTP server where the batch processor can connect to and upload ITF files. The ITF files then will be edited and then be written to HDFS.

Dependencies
---
To run MockMVS in a cluster, we'll need to have the following running and working in the same cluster:
- HDFS

Tasks
---
- **deploy.yml** - Will deploy MockMVS into the specified server.

Configuration
---
|   Variable                |  Default Value                | Description                                                      |
| :------------------------:|:-----------------------------:|:-----------------------------------------:|
| mockmvs_username          | "root"                        | User for which MockMVS service going to be run as. |
| mockmvs_version           | "0.1.0-rc1.el7.centos.x86_64" | MockMVS version that's going to be deployed |
| mockmvs_install_dir       | "/opt/app/mockmvs"            | Directory in which MockMVS will be installed |
| mockmvs_ftp_auth_port     | 21                            | FTP port that will be used for communication |
| mockmvs_ftp_pasv_min_port | 28010                         | The lower end of the data port that will be used for PASV. |
| mockmvs_ftp_pasv_max_port | 28019                         | The higher end of the data port that will be used for PASV. |
| mockmvs_hdfs_root_dir     | "/mockmvs"                    | HDFS root directory where mockmvs will write its data /
| mockmvs_hdfs_username     | "hdfs"                        | HDFS username /
| mockmvs_hdfs_perm         | 766                           | HDFS file permission /
