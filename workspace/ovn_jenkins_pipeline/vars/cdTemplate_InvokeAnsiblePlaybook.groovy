// This shared library invokeAnsiblePlaybook is to be used as a template across CD jobs for a definite structure


def call( String repoName, String branchName, String playbookName, def extra_vars='-e optional=true' ){

pipeline {
  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
      args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
    }
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '15'))
  }
  parameters {
        string(name: 'extra_vars', defaultValue: '', description: '<BR>Example goes here -e extra_vars</BR>')
        string(name: 'OVN_PLAYBOOK_BRANCH_OVERRIDE', defaultValue: '', description: 'Leave this blank if you want to keep the <i>default</i><BR>Mention the branch if you want to <b>override</b> the <i>default</i>')
        }
  stages {
    stage("Dry run to grab parameters") {
      steps {
        script {
             if ("${BUILD_NUMBER}" == "1") {
             currentBuild.result = 'ABORTED'
             error('DRY RUN COMPLETED. JOB PARAMETERIZED.')
                    }
                }
            }
        }
        stage("GET/SET playbook branch") {
                    steps {
                        ansiColor('xterm') {
                            script {
                                // NOTE:  We expect the DEFAULT_PLAYBOOK_BRANCH env Variable to be stored in the Jenkins CD instance
                                //        And it will be set to master on DEV, and or EPIC-X on EPIC deploys
                                if (env.OVN_PLAYBOOK_BRANCH_OVERRIDE != null && env.OVN_PLAYBOOK_BRANCH_OVERRIDE !='') {
                                    branchName = env.OVN_PLAYBOOK_BRANCH_OVERRIDE
                                } else if (env.DEFAULT_PLAYBOOK_BRANCH != null) {
                                    branchName = env.DEFAULT_PLAYBOOK_BRANCH
                                } else if (env.RELEASE_BRANCH != null) {
                                    branchName = env.RELEASE_BRANCH
                                } else {
                                    branchName = 'master'
                                }
                                currentBuild.description = "${playbookName} (${branchName})"
                                echo "\u001B[34mUsing branch: ${branchName} from repo: ${repoName} \u001B[0m"
                            }
                        }
                    }
                }

                stage("Checkout playbook repository") {
                         steps {
                             checkout poll: false, scm: [$class: 'GitSCM', branches: [[name: "${branchName}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'ssh://git@stash.trusted.visa.com:7999/op/' + repoName + '.git']]]
                         }
                     }
                     stage('Run ansible playbook') {
                         steps {
                             ansiColor('xterm') {
                                 ansiblePlaybook colorized: true, credentialsId: 'ENV.root_key', inventory: "inventories/${env.CLUSTER}/${env.DATACENTER}", playbook: "$playbookName", extras: "$extra_vars"
                             }
                         }
                     }
                 }
             }
       }
