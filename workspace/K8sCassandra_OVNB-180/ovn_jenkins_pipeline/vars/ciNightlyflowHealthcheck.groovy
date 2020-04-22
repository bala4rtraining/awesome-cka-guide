// Shared library to define ci-authnightly flow declarative pipelines depending on the flowtype
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax///declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameters.
// First parameter is the flowtype and second is the environment e.g. : ciAuthNightlyFlow('authConfig', 'integration')
def call(String flow, String clusterName){
//********************************************************************************************************************
if (flow == 'authHealthCheck'){
//********************************************************************************************************************
pipeline {
agent {
  docker {
    image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
    label 'ovn_build'
    args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
  }
}
options {

    buildDiscarder(logRotator(numToKeepStr: '95'))
}
environment {
  CLUSTER = "${clusterName}"
  DATACENTER1 = 'dc1'
  DATACENTER2 = 'dc2'
}
stages{
stage('Checkout SCM'){
            steps{
            git credentialsId: 'ENV.root_key', url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_app_infrastructure.git'
            }
        }

    stage('Run ci-nightly-healthcheck '){
        steps{
           ansiColor('xterm') {
           ansiblePlaybook credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER1',  colorized: true, playbook: 'ansible_ovn/ci-nightly-auth-healthcheck.yml', sudoUser: null
           ansiblePlaybook credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER2',  colorized: true, playbook: 'ansible_ovn/ci-nightly-auth-healthcheck.yml', sudoUser: null
        }
      }
    }

  }
 }
}
//********************************************************************************************************************************
if(flow == 'clearingHealthCheck') {
//*******************************************************************************************************************************
  pipeline {
  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
      args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
    }
  }
  options {

      buildDiscarder(logRotator(numToKeepStr: '95'))
  }
  environment {
    CLUSTER = "${clusterName}"
    DATACENTER1 = 'dc1'
    DATACENTER2 = 'dc2'
  }
  stages{

  stage('Checkout SCM'){
          steps{
          git credentialsId: 'ENV.root_key', url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_app_infrastructure.git'
          }
      }
      stage('Run ci-nightly-clearing-healthcheck '){
          steps{
             ansiColor('xterm') {
             ansiblePlaybook credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER1',  colorized: true, playbook: 'ansible_ovn/ci-nightly-clearing-healthcheck.yml', sudoUser: null
             ansiblePlaybook credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER2',  colorized: true, playbook: 'ansible_ovn/ci-nightly-clearing-healthcheck.yml', sudoUser: null
          }
        }
      }
    }
   }
  }
  }
