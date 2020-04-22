// Shared library to define ci-authnightly flow declarative pipelines depending on the flowtype
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax///declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameters.
// First parameter is the flowtype and second is the environment e.g. : ciAuthNightlyFlow('authConfig', 'integration')
def call(String flow, String clusterName, String branchName){
if (flow == 'configManifest'){
pipeline {
  agent {
    docker {
      image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
      label 'ovn_build'
      args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
    }
   }
  environment {
    CLUSTER = "${clusterName}"
    DATACENTER1 = 'dc1'
    DATACENTER2 = 'dc2'
    BRANCH_NAME = "${branchName}"
  }
    parameters {
        choice(name:'BUILD', choices: 'latest_successful_build\ncurrent_release_level', description: 'Release will archive release_manifest and latest will archive latest_successful_build from Artifactory')
    }
  stages {
  stage('Checkout SCM'){
            steps{
            git credentialsId: 'ENV.root_key', url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_app_infrastructure.git'
            }
        }
      stage('Retrieve latest Artifacts') {
        when {
              expression { params.BUILD == "latest_successful_build" }
        }
        steps{
            sh '''
            #!/bin/bash -e
              sh jenkins-app-sh/artifactory-list.sh ${BRANCH_NAME} > artifactnames.txt
              rm -f release_manifest.yml
              cp app_vars/release_manifest.yml .
              nomad="`grep nomad release_manifest.yml`"
              sed -i '/$nomad/d' release_manifest.yml
              grep -v -i  "tarball" release_manifest.yml > tmp.yml
              mv tmp.yml release_manifest.yml
              grep -v -i "rpm" release_manifest.yml > tmp.yml
              mv tmp.yml release_manifest.yml
              cat release_manifest.yml
              echo -e "\n#rpms" >> release_manifest.yml
              proc="`grep "cfprocessor" artifactnames.txt`"
              procname="`echo $proc | cut -d"-" -f1`"
              echo ""$procname"_rpm: \\"$proc\\"" >> release_manifest.yml
              bridge="`grep "bridgeeafetch" artifactnames.txt`"
              bridgename="`echo $bridge | cut -d"-" -f1`"
              echo -e ""$bridgename"_rpm: \\"$bridge\\"" >> release_manifest.yml
              bin="`grep "vss-" artifactnames.txt`"
              binname="`echo $bin | cut -d"-" -f1`"
              echo ""$binname"_rpm: \\"$bin\\"" >> release_manifest.yml
              wrap="`grep "vsswrapper" artifactnames.txt`"
              wrapname="`echo $wrap | cut -d"-" -f1`"
              echo ""$wrapname"_rpm: \\"$wrap\\"" >> release_manifest.yml
              echo "\n#Tarballs" >> release_manifest.yml
              grep -v "rpm" artifactnames.txt > tar.txt
              while read repo; do name="`echo $repo | cut -d"-" -f1`" && echo ""$name"_tarball: \\"$repo\\"" >> release_manifest.yml; done< tar.txt
              echo "$nomad" >> release_manifest.yml
              rm -f tar.txt
            '''
        }
    }
    stage('load the nightly_release_manifest') {
        when {
            expression { params.BUILD == "current_release_level" }
        }
        steps {
              sh '''cp app_vars/release_manifest.yml release_manifest.yml
              cat release_manifest.yml
        '''
      }
    }

    stage('push release artifacts to ovn-app-temp artifactory') {
       steps{
            sh '''#!/bin/bash -e
            sh jenkins-app-sh/push-artifacts-app-temp.sh
         '''
        }
      }

    stage('archiving artifacts') {
       steps{
            archiveArtifacts 'release_manifest.yml'

        }
      }
    }
  post {
      success {
          withCredentials([sshUserPrivateKey(credentialsId: 'stash', keyFileVariable: 'SSH_KEY')]) {
              sh '''
      git checkout ${BRANCH_NAME}
      git checkout -B nightly-${CLUSTER} ${BRANCH_NAME}
      git fetch origin nightly-${CLUSTER}:nightly-${CLUSTER} || true
      cp release_manifest.yml app_vars/release_manifest.yml
      rm -rf release_manifest.yml
      rm -rf list.txt
      git add app_vars/release_manifest.yml
      git commit -q -m "release_manifest.yml: Update with new nightly build" || true
      git clean -f
      git push -f origin nightly-${CLUSTER}
         '''
          }
      }
     }
   }
 }
}
