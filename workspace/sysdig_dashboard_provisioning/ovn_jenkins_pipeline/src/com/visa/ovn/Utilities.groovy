package com.visa.ovn;

// This class returns the cluster
// And the datacenter from the folder name
// that contains the job.
//
// The possible values for the folder names are
// - test1 :  QA test1 cluster
// - test2 :  QA test2 cluster
// -   dci :  Indonesia DCI datacenter
// - telin :  Indonesia Telin datacenter

class Utilities {

  static class Cluster implements Serializable {
    String cluster;
    String datacenter;
    String env;
  }

  static def setClusterDatacenter(env) {
    def jobName = env.JOB_NAME;
    def jobBaseName = env.JOB_BASE_NAME;
    def jobNameLen = jobName.length();
    def jobBaseNameLen = jobBaseName.length();
    def folder = jobName;
    if (jobNameLen > jobBaseNameLen) {
      folder = jobName.substring(0, jobNameLen - (jobBaseNameLen + 1));
    }
    folder = folder.substring(folder.lastIndexOf('/') + 1);

    def c = new Cluster();
    c.cluster = '';
    c.datacenter = '';
    switch (folder.toLowerCase()) {
      case 'dev1':
        c.cluster='dev';
        c.datacenter='dc1';
        c.env='dev1';
        break;
      case 'dev2':
        c.cluster='dev';
        c.datacenter='dc2';
        c.env='dev2';
        break;
      case 'test1':
        c.cluster='test';
        c.datacenter='dc1';
        c.env='test1';
        break;
      case 'test2':
        c.cluster='test';
        c.datacenter='dc2';
        c.env='test2';
        break;
      case 'dci':
        c.cluster='indonesia';
        c.datacenter='dc1';
        c.env='prod.indonesia-dci';
        break;
      case 'telin':
        c.cluster='indonesia';
        c.datacenter='dc2';
        c.env='prod.indonesia-telin';
        break;
      default:
        if (env.CLUSTER != null && env.DATACENTER != null) {
          return;
        }
        throw new RuntimeException("Folder `" + folder + "` is not a valid OVN folder name.  Folder name should be: DEV1, DEV2, TEST1, TEST2, DCI, or TELIN.")
    }
    // set environment variable to the cluster and the datacenter
    // discovered from the folder name.
    env.CLUSTER = c.cluster;
    env.DATACENTER = c.datacenter;
    env.ENV = c.env;
  }

} 