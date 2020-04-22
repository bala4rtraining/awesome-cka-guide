// Shared library to define ci-authnightly flow declarative pipelines depending on the flowtype
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax///declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameters.
// First parameter is the flowtype and second is the environment e.g. : ciAuthNightlyFlow('authConfig', 'integration')
def call(String flow, String clusterName){
//*******************************************************************************************************************
//*                                                                                                                 *
if (flow == 'authMaster'){
//********************************************************************************************************************
pipeline {
    agent {
        docker {
            image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
            label 'ovn_build'
            args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
        }
    }
    triggers {
        cron('H 0 * * *')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    stages {
    stage('Prepare') {
           steps {
               sh '''
                   git show -s --pretty=%ce > .git/committer-email
                   echo .git/committer-email
               '''
           }
       }
      stage('CI-nightly-authconfig'){
            steps{
                build 'CI-nightly-'+ clusterName + '-authconfig'
           }
        }
        stage('DEPLOY auth infrastructure') {
            steps{
                build 'CI-nightly-'+ clusterName + '-auth-infra-deploy'
            }
        }
        stage('DEPLOY auth application') {
            steps{
                build 'CI-nightly-'+ clusterName + '-auth-app-deploy'
            }
        }
        stage('RUN auth healthcheck') {
            steps{
                build 'ci-nightly-auth-'+ clusterName + '-healthcheck'
            }
        }
        stage('RUN Acceptance test (AUTH)') {
            steps{
                build 'CI-nightly-'+ clusterName + '-authtest1'
            }
        }
        stage('RUN Loadtest (AUTH)') {
            steps{
                build 'CI-nightly-'+ clusterName + '-authloadtest1'
            }
        }
    }
    post {
    failure {
             script {
                 def committer_email = readFile('.git/committer-email').trim()
                 mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. \n More info at ${BUILD_URL} \n Last committer was: ${committer_email}\n ${GIT_COMMIT} ",
                 subject: "${JOB_NAME} job: Build failed testing wider recipient ",
                 to: "GDL - OVN Nightly alerts <GDLOVNNightlyalerts@visa.com>, ${committer_email}"


                     //def committer_email = readFile('.git/committer-email').trim()
                     //mail body: " ${JOB_NAME} build success." ,
                     //subject: "Build fail.........." ,
                     //to: " ${committer_email}"
          }
       }
     }
 }
}


 //*******************************************************************************************************************
//*                                                                                                                 *
if (flow == 'clearingMaster'){
//********************************************************************************************************************
  pipeline {
    agent {
        docker {
            image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
            label 'ovn_build'
            args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
        }
    }
    triggers {
        cron('H 0 * * *')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    stages {
    stage('Prepare') {
           steps {
               sh '''
                   git show -s --pretty=%ce > .git/committer-email
                   echo .git/committer-email
               '''
           }
       }
        stage('CI-nightly-clearing-config'){
            steps{
                build 'CI-nightly-'+ clusterName + '-clearing-config'
           }
        }
        stage('DEPLOY clearing infrastructure') {
            steps{
                build 'CI-nightly-'+ clusterName + '-clearing-infra-deploy'
            }
        }
        stage('DEPLOY clearing application') {
            steps{
                build 'CI-nightly-'+ clusterName + '-clearing-app-deploy'
            }
        }
        stage('RUN clearing healthcheck') {
            steps{
                build 'CI-nightly-'+ clusterName + '-clearing-healthcheck'
            }
        }
        stage('RUN Acceptance test (CLR)') {
            steps{
                build 'CI-nightly-'+ clusterName + '-clearing-test'
            }
        }
     }
     post {
     failure {
              script {
                  def committer_email = readFile('.git/committer-email').trim()
                  mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. \n More info at ${BUILD_URL} \n Last committer was: ${committer_email}\n ${GIT_COMMIT} ",
                  subject: "${JOB_NAME} job: Build failed testing wider recipient ",
                  to: "GDL - OVN Nightly alerts <GDLOVNNightlyalerts@visa.com>, ${committer_email}"


                      //def committer_email = readFile('.git/committer-email').trim()
                      //mail body: " ${JOB_NAME} build success." ,
                      //subject: "Build fail.........." ,
                      //to: " ${committer_email}"
           }
        }
      }
   }
  }
}
