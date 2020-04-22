// Shared library to define ci-authnightly flow declarative pipelines depending on the flowtype
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax///declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameters.
// First parameter is the flowtype and second is the environment e.g. : ciAuthNightlyFlow('authConfig', 'integration')
def call(String flow, String clusterName, String branchName){
//******************************************************************************************************************
//* authInfraDeploy                                                                                                 *
//******************************************************************************************************************
if (flow == 'authInfraDeploy'){
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
    RELEASE_ARTIFACTORY_URL=https://artifactory.trusted.visa.com/ovn-releases/ovn-app-temp-el7
  }
  stages {
  stage('Checkout SCM'){
            steps{
            git credentialsId: 'ENV.root_key', branch: "${branchName}", url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git'
            }
        }
    stage('stop firewalld') {
      steps{
        script {
          ansiColor('xterm') {
              ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER1', extras: ' -e "firewalld_state=stopped"', playbook: 'ansible_firewalld/firewalld_service.yml', sudoUser: null
              ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER2', extras: ' -e "firewalld_state=stopped"', playbook: 'ansible_firewalld/firewalld_service.yml', sudoUser: null

          
          }
        }
      }
    }

    stage('clean-cluster-state') {
      steps{
        script {
          def clean = [:]
          clean["clean-${DATACENTER1}"] = runPlaybookWithRetry("ansible_ovn/clean_state.yml", 2, "${CLUSTER}", "${DATACENTER1}")
          clean["clean-${DATACENTER2}"] = runPlaybookWithRetry("ansible_ovn/clean_state.yml", 2, "${CLUSTER}", "${DATACENTER2}")
          parallel clean
        }
      }
    }
    stage('run set_cluster_facts_infra') {
        steps {
          ansiColor('xterm'){
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER', playbook: 'ansible_ovn/set_cluster_facts_infra.yml', sudoUser: null, extras: '-e  DATACENTER="${DATACENTER2}"'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER', playbook: 'ansible_ovn/set_cluster_facts_infra.yml', sudoUser: null, extras: ' -e  DATACENTER="${DATACENTER1}"'
          }
        }
    }
    stage('deploy-middleware-infrastructure') {
      steps{
          script {
            def zookeepers = [:]
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER1}", playbook: 'ansible_zookeeper/provision.yml'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER2}", playbook: 'ansible_zookeeper/provision.yml'
            parallel zookeepers
          }
          script {
            def infra = [:]
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER1}", playbook: 'ansible_kafka/site.yml'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER2}", playbook: 'ansible_kafka/site.yml'
            infra["riak-${DATACENTER1}"] = runPlaybook("ansible_riak/site.yml", "${CLUSTER}", "${DATACENTER1}", 5, '-e "ALLOW_OVNINFRA_PLAYBOOK=true"')
            infra["riak-${DATACENTER2}"] = runPlaybook("ansible_riak/site.yml", "${CLUSTER}", "${DATACENTER2}", 5, '-e "ALLOW_OVNINFRA_PLAYBOOK=true"')
            //TODO enable dependency on build
            //infra["profile-${DATACENTER1}"] = runPlaybookWithRetry("ansible_ovn/deploy_profile.yml", 2, "${CLUSTER}", "${DATACENTER1}")
            //infra["profile-${DATACENTER2}"] = runPlaybookWithRetry("ansible_ovn/deploy_profile.yml", 2, "${CLUSTER}", "${DATACENTER2}")
            //infra["currency-${DATACENTER1}"] = runPlaybookWithRetry("ansible_ovn/deploy_currency.yml", 2, "${CLUSTER}", "${DATACENTER1}")
            //infra["currency-${DATACENTER2}"] = runPlaybookWithRetry("ansible_ovn/deploy_currency.yml", 2, "${CLUSTER}", "${DATACENTER2}")
            parallel infra
          }
      }
    }
  }
}
}
//*******************************************************************************************************************
//* authAppDeploy                                                                                                         *
//********************************************************************************************************************
if (flow == 'authAppDeploy'){
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
  stages {
    stage('checkout Master-CI-nightly'){
      steps{
        git branch: "nightly-${CLUSTER}", changelog: false, credentialsId: 'ENV.root_key', poll: false, url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_app_infrastructure.git'

          }
        }
    stage('Run set_cluster_facts_app') {
        steps {
          ansiColor('xterm'){
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER', playbook: 'ansible_ovn/set_cluster_facts_app.yml', sudoUser: null, extras: '-e DATACENTER="${DATACENTER1}"'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER', playbook: 'ansible_ovn/set_cluster_facts_app.yml', sudoUser: null, extras: ' -e DATACENTER="${DATACENTER2}"'
          }
        }
    }
    stage('deploy-authorization-application') {
      steps{
        script {
          def auth = [:]
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER1}", playbook: 'ansible_ovn/provision.yml', extras: '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}"'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key',  inventory: "inventories/${CLUSTER}/${DATACENTER2}", playbook: 'ansible_ovn/provision.yml', extras: '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}"'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${CLUSTER}/${DATACENTER1}", playbook: 'ansible_ovn/umf_broker.yml', extras: '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}" -e umf_broker=true -e umf_delivery_ub2=true'
            ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key',  inventory: "inventories/${CLUSTER}/${DATACENTER2}", playbook: 'ansible_ovn/umf_broker.yml', extras: '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}" -e umf_broker=true -e umf_delivery_ub2=true'
            auth["multidc_sync-${DATACENTER1}"] = runPlaybook("ansible_ovn/ovn_multidc_sync.yml", "${CLUSTER}", "${DATACENTER1}", 5, '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}"' )
            auth["multidc_sync-${DATACENTER2}"] = runPlaybook("ansible_ovn/ovn_multidc_sync.yml", "${CLUSTER}", "${DATACENTER2}", 5, '-e "release_artifactory_url=${RELEASE_ARTIFACTORY_URL}"')
            parallel auth
        }
      }
    }
  }
 }
}
//********************************************************************************************************************
//* clearingInfraDeploy                                                                                               *
//*******************************************************************************************************************
if(flow == 'clearingInfraDeploy'){
pipeline {
  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
      args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/'
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

stages {
stage('Checkout SCM'){
        steps{
        git credentialsId: 'ENV.root_key', branch: "${branchName}", url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git'
        }
    }
    stage('stop') {
    steps{
      parallel(
        'stop-hadoop-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/stop_hadoop_cluster.yml'
          }
        },
        'stop-hadoop-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/stop_hadoop_cluster.yml'
          }
        }
      )
    }
  }

  stage('clean'){
    steps {
      parallel(
        'clean-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook(colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/clean_state.yml')
          }
        },
        'clean-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook(colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/clean_state.yml')
          }
        },
        'clean-hadoop-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/clean_hadoop.yml', extras: '-e hadoop_reinstall=true'
          }
        },
        'clean-hadoop-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/clean_hadoop.yml', extras: '-e hadoop_reinstall=true'
          }
        }
      )
    }
  }

  stage('init') {
    steps{
      parallel(
        'init-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}", playbook: 'ansible_ovn/set_cluster_facts_infra.yml', extras: '-e DATACENTER="${env.DATACENTER1}"'
          }
        },
        'init-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}", playbook: 'ansible_ovn/set_cluster_facts_infra.yml', extras: '-e DATACENTER="${env.DATACENTER2}"'
          }
        }
      )
    }
  }

  stage('zookeeper-deploy') {
    steps{
      parallel(
        'zookeeper-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_zookeeper/provision.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml"
          }
        },
        'zookeeper-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_zookeeper/provision.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml"
          }
        }
      )
    }
  }

  stage('kafka-deploy') {
    steps{
      parallel(
        'kafka-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_kafka/site.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml"
          }
        },
        'kafka-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_kafka/site.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml"
          }
        }
      )
    }
  }

  stage('riak-deploy') {
    steps{
      parallel(
        'riak-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_riak/site.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml"
          }
        },
        'riak-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_riak/site.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml"
          }
        }
      )
    }
  }

  stage('nomad-deploy') {
    steps{
      parallel(
        'nomad-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/deploy_nomad.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml"
          }
        },
        'nomad-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/deploy_nomad.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml"
          }
        }
      )
    }
  }
  stage('copy_encrypted_dek') {
    steps{
      parallel(
        'copy_encrypted_dek-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/copy_encrypted_dek.yml', extras: "-e @config/${env.ENV}.vars.secret.yml"
          }
        },
        'copy_encrypted_dek-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/copy_encrypted_dek.yml', extras: "-e @config/${env.ENV}.vars.secret.yml"
          }
        }
      )
    }
  }

  stage('docker_ea-deploy') {
    steps{
      parallel(
        'docker_ea-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/deploy_docker_ea.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml"
          }
        },
        'docker_ea-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/deploy_docker_ea.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml"
          }
        }
      )
    }
  }
  stage('hadoop-deploy') {
    steps{
      parallel(
        'hadoop-dc1': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER1}", playbook: 'ansible_ovn/hadoop.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER2}.yml --extra-vars '{hadoop_reinstall: True}'"
          }
        },
        'hadoop-dc2': {
          ansiColor('xterm') {
            ansiblePlaybook colorized: true, credentialsId: "ENV.root_key", inventory: "inventories/${env.CLUSTER}/${env.DATACENTER2}", playbook: 'ansible_ovn/hadoop.yml', extras: "-e @/tmp/vars_about_${env.CLUSTER}_${env.DATACENTER1}.yml --extra-vars '{hadoop_reinstall: True}'"
          }
        }
      )
    }
  }

}
}
}
// *******************************************************************************************************************
 //* clearingAppDeploy                                                                                                                *
//********************************************************************************************************************
if(flow == 'clearingAppDeploy'){
pipeline {
  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
       args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/'
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

  stages {
  stage('Checkout SCM'){
          steps{
          git credentialsId: 'ENV.root_key', branch: "nightly-${CLUSTER}", url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_app_infrastructure.git'
          }
      }
stage('deploying Clearing application'){
   steps {
    ansiColor('xterm') {
      script {
        def clearing_1 = [:]
        clearing_1["deploy_cas_tools-${DATACENTER1}"] = runPlaybook("ansible_ovn/deploy_cas_tools.yml", "${CLUSTER}", "${DATACENTER1}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
        clearing_1["deploy_cas_tools-${DATACENTER2}"] = runPlaybook("ansible_ovn/deploy_cas_tools.yml", "${CLUSTER}", "${DATACENTER2}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
        parallel clearing_1
        }
        script {
        def clearing_2 = [:]
        clearing_2["set_cluster_facts_app-${DATACENTER1}"] = runPlaybook("ansible_ovn/set_cluster_facts_app", "${CLUSTER}", 5, "-e DATACENTER=${DATACENTER1}")
        clearing_2["set_cluster_facts_app-${DATACENTER2}"] = runPlaybook("ansible_ovn/set_cluster_facts_app.yml", "${CLUSTER}", 5, "-e DATACENTER=${DATACENTER2}")
        parallel clearing_2
        }
        script {
        def clearing_3 = [:]
        clearing_3["deploy_xdc_sync-${DATACENTER1}"] = runPlaybook("ansible_ovn/deploy_xdc_sync.yml", "${CLUSTER}", "${DATACENTER1}", 5, "-e @config/${CLUSTER}.vars.secret.yml -e @/tmp/vars_about_${CLUSTER}_${DATACENTER2}.yml")
        clearing_3["deploy_xdc_sync-${DATACENTER2}"] = runPlaybook("ansible_ovn/deploy_xdc_sync.yml", "${CLUSTER}", "${DATACENTER2}", 5, "-e @config/${CLUSTER}.vars.secret.yml -e @/tmp/vars_about_${CLUSTER}_${DATACENTER1}.yml")
        parallel clearing_3
        }
        script {
        def clearing_4 = [:]
        clearing_4["deploy_parameterized_jobs_bridge_ea_fetch-${DATACENTER1}"] = runPlaybook("ansible_nomad/deploy_parameterized_jobs_bridge_ea_fetch.yml", "${CLUSTER}", "${DATACENTER1}")
        clearing_4["deploy_parameterized_jobs_bridge_ea_fetch-${DATACENTER2}"] = runPlaybook("ansible_nomad/deploy_parameterized_jobs_bridge_ea_fetch.yml", "${CLUSTER}", "${DATACENTER2}")
        parallel clearing_4
        }
        script {
        def clearing_5 = [:]
        clearing_5["deploy_parameterized_jobs_cfprocessor-${DATACENTER1}"] = runPlaybook("ansible_nomad/deploy_parameterized_jobs_cfprocessor.yml", "${CLUSTER}", "${DATACENTER1}")
        clearing_5["deploy_parameterized_jobs_cfprocessor-${DATACENTER2}"] = runPlaybook("ansible_nomad/deploy_parameterized_jobs_cfprocessor.yml", "${CLUSTER}", "${DATACENTER2}")
        parallel clearing_5
        }
        script {
          def clearing_6 = [:]
          clearing_6["clearing_job_nomad-${DATACENTER1}"] = runPlaybook("ansible_ovn/clearing_job_nomad.yml", "${CLUSTER}", "${DATACENTER1}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          clearing_6["clearing_job_nomad-${DATACENTER2}"] = runPlaybook("ansible_ovn/clearing_job_nomad.yml", "${CLUSTER}", "${DATACENTER2}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          parallel clearing_6
          }
          script {
          def clearing_7 = [:]
          clearing_7["clearing_master_job_deploy-${DATACENTER1}"] = runPlaybook("ansible_ovn/clearing_master_job_deploy.yml", "${CLUSTER}", "${DATACENTER1}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          clearing_7["clearing_master_job_deploy-${DATACENTER2}"] = runPlaybook("ansible_ovn/clearing_master_job_deploy.yml", "${CLUSTER}", "${DATACENTER2}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          parallel clearing_7
          }
          script {
          def clearing_8 = [:]
          clearing_8["clearing_install_certs-${DATACENTER1}"] = runPlaybook("ansible_ovn/clearing_install_certs.yml", "${CLUSTER}", "${DATACENTER1}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          clearing_8["clearing_install_certs-${DATACENTER2}"] = runPlaybook("ansible_ovn/clearing_install_certs.yml", "${CLUSTER}", "${DATACENTER2}", 5, "-e @config/${CLUSTER}.vars.secret.yml")
          parallel clearing_8
          }
        }
       }
     }
    } //stages
   }
 }
//*******************************************************************************************************************
//*         VSS-infra-deploy                                                                                         *                                                                              
//********************************************************************************************************************
if (flow == 'VSS-infra-deploy'){ 
pipeline {

  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
      args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/'
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

 stages {
 stage('Checkout SCM'){
          steps{
           git credentialsId: 'ENV.root_key', branch: "${branchName}", url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git'
           }
       }

   stage ('deploying Vss_production infrastructure'){
     steps {
       script {
         def zookeepers = [:]
         zookeepers["zookeeper-${DATACENTER1}"] = runPlaybookWithRetry("ansible_zookeeper/provision.yml", 2, "${CLUSTER}", "${DATACENTER1}")
         zookeepers["zookeeper-${DATACENTER2}"] = runPlaybookWithRetry("ansible_zookeeper/provision.yml", 2, "${CLUSTER}", "${DATACENTER2}")
         parallel zookeepers
       }
       ansiColor('xterm'){
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', extras: '-e -vv', forks: 5, inventory: 'inventories/$CLUSTER/$DATACENTER1', playbook: 'ansible_ovn/stop_hadoop_cluster.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', extras: '-e -vv', forks: 5, inventory: 'inventories/$CLUSTER/$DATACENTER2', playbook: 'ansible_ovn/stop_hadoop_cluster.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER1' ,extras: '-e hadoop_reinstall=true', playbook: 'ansible_ovn/clean_hadoop.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: 'inventories/$CLUSTER/$DATACENTER2' ,extras: '-e hadoop_reinstall=true', playbook: 'ansible_ovn/clean_hadoop.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', extras: '-e ovn_artifactory_repo_url=https://10.55.65.116/ovn/repo  --extra-vars \'{hadoop_reinstall: True}\'', inventory: 'inventories/$CLUSTER/$DATACENTER1', playbook: 'ansible_ovn/hadoop.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', extras: '-e ovn_artifactory_repo_url=https://10.55.65.116/ovn/repo  --extra-vars \'{hadoop_reinstall: True}\'', inventory: 'inventories/$CLUSTER/$DATACENTER2', playbook: 'ansible_ovn/hadoop.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER/$DATACENTER1', playbook: 'ansible_ovn/deploy_nomad.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER/$DATACENTER2', playbook: 'ansible_ovn/deploy_nomad.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER/$DATACENTER1', playbook: 'ansible_riak/site.yml', sudoUser: null
         ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', forks: 20, inventory: 'inventories/$CLUSTER/$DATACENTER2', playbook: 'ansible_riak/site.yml', sudoUser: null

          }
        }
      }
     }
    }
  }
}
