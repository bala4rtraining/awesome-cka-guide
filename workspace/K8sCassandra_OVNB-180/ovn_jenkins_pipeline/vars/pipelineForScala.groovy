//
// Shared library to define different declarative pipelines depending on
// the type either service or library.
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameter.
// - ptype : 'service' | 'library'
// - reponame : Name of library repository name in upper case. This parameter is mandatory for ptype 'library'

def call(String ptype, String reponame=null) {

    pipeline {
        agent {
            docker {
                image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
                label 'ovn_build'
                args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh -v /home/was:/home/was -v /opt/app/ivy2/cache:/opt/app/ivy2/cache'
            }
        }

        environment {
            PTYPE = "${ptype}"
            REPONAME = "${reponame}"
            DEVCRED = credentials('svcnpovndev_id')
            STGCRED = credentials('svcnpovnstg_artifactory')
        }

        options { timeout(time: 1, unit: 'HOURS') }

        stages {

            stage('Prepare') {
                steps {
                    sh '''
		                git show -s --pretty=%ce > .git/committer-email
		            '''
                }
            }

            stage('Build application') {
                steps {
                    ansiColor('xterm') {
                        sh returnStatus: true, script: '''/usr/local/sbt/bin/sbt clean package'''
                    }
                }
            }


            stage('Style check') {
                when {
                    anyOf {
                        branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*'
                    }
                }
                steps {
                    ansiColor('xterm') {
                        sh returnStatus: true, script: '''/usr/local/sbt/bin/sbt scalastyle
		                '''
                    }
                }
            }

            stage('Unit test') {
                when {
                    anyOf {
                        branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*'
                    }
                }
                steps {
                    ansiColor('xterm') {
                        sh returnStatus: true, script: '''
		                /usr/local/sbt/bin/sbt test'''
                    }
                }
            }
            stage('Build package (scala jar library)') {
               when { expression { PTYPE ==~ /(library)/ }}
		        steps {
		            ansiColor('xterm') {
		              sh returnStatus: true, script: '''/usr/local/sbt/bin/sbt clean package'''
  		              archiveArtifacts artifacts: 'target/*/*.jar', fingerprint: true
		           }
		        }
		    }

            stage('Build release package') {
                when { expression { PTYPE ==~ /(service)/ }
                anyOf { branch 'epic-*'; branch 'release-*'; branch 'master' } }

                steps {
                ansiColor('xterm') {
                    sh '''
		              /usr/local/sbt/bin/sbt universal:packageZipTarball
		              for i in target/universal/*.tgz; do mv "$i" "${i%.*}-${BRANCH_NAME}-build${BUILD_ID}".tgz; done
		              '''
                    archiveArtifacts 'target/universal/*.tgz'
                }
                }
            }

            stage('Acceptance tests') {
            when {
                anyOf {
                    branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*';
                    branch 'release-*'
                }
            }
                steps {
                ansiColor('xterm') {
                    echo "\u001B[31mThe Acceptance Test step for this jenkinsfile is TBD\u001B[m"
                }
                }
            }

            stage('Post-build steps') {
            when {
                anyOf {
                    branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*';
                    branch 'release-*'
                }
            }
            steps {
                // scala warnings check
                warnings canComputeNew: false, canResolveRelativePaths: false, categoriesPattern: '', consoleParsers: [[parserName: 'Scala Compiler (scalac)']], defaultEncoding: '', excludePattern: '', healthy: '', includePattern: '', messagesPattern: '', unHealthy: ''
            }
            }

            stage('Publish SNAPSHOT to Artifactory') {
            when {
                expression { PTYPE ==~ /(service)/ }
                anyOf { branch 'master'; branch 'epic-*' }
            }

            steps {
                script {
                    def artifactory = Artifactory.server('ovn-artifactory')
                    def buildInfo = Artifactory.newBuildInfo()
                    buildInfo.env.capture = true
                    def uploadSpec =
                            """{"files":
		                             [{"pattern": "target/universal/*.tgz",
		                               "target": "ovn-app-temp-el7",
		                               "recursive": "false"}]
		                           }"""
                    artifactory.upload(uploadSpec, buildInfo)
                    artifactory.publishBuildInfo(buildInfo)
                }
                }
            }

            stage('Publish RELEASE to Artifactory') {
            when {
                expression { PTYPE ==~ /(service)/ }
                allOf { branch 'release-*'; expression { return params.BUILD_AND_PUBLISH } }
            }

            steps {
                script {
                    def artifactory = Artifactory.server('ovn-artifactory')
                    def buildInfo = Artifactory.newBuildInfo()
                    buildInfo.env.capture = true
                    def uploadSpec =
                            """{"files":
		                             [{"pattern": "target/universal/*.tgz",
		                               "target": "ovn-app-el7",
		                               "recursive": "false"}]
		                           }"""
                    artifactory.upload(uploadSpec, buildInfo)
                    artifactory.publishBuildInfo(buildInfo)
                }
            }
            }
            stage('Publish SNAPSHOT to Artifactory using sbt') {
            when {
                expression { PTYPE ==~ /(library)/ }
                anyOf { branch 'release'; branch 'epic-*'; branch 'bugfix/OVN-*'; branch 'PR-*' }
            }
                steps {
                    ansiColor('xterm') {
                        sh '''printf "realm=Artifactory Realm\nhost=artifactory.trusted.visa.com\nuser=$DEVCRED_USR\npassword=$DEVCRED_PSW" > ${HOME}/.ivy2/.credentials'''
                        sh returnStatus: true, script: '''/usr/local/sbt/bin/sbt publish'''
                        sh '''rm -f ${HOME}/.ivy2/.credentials'''
                    }
                }
		    }

		    stage('Publish RELEASE to Artifactory using sbt') {
            when {
                expression { PTYPE ==~ /(library)/ }
                anyOf { branch 'release-*'}
            }
                steps {
                    ansiColor('xterm') {
                        sh '''printf "realm=Artifactory Realm\nhost=artifactory.trusted.visa.com\nuser=$STGCRED_USR\npassword=$STGCRED_PSW" > ${HOME}/.ivy2/.credentials'''
                        sh returnStatus: true, script: '''/usr/local/sbt/bin/sbt -DovnReleaseBuild=YES publish'''
                        sh '''rm -f ${HOME}/.ivy2/.credentials'''
                    }
                }
		    }
            stage('Publish RELEASE to OVN-Release Artifactory') {
            when {
                expression { PTYPE ==~ /(service)/ }
                allOf { branch 'release-*'; expression { return params.BUILD_AND_PUBLISH } }
            }

            steps {
                script {
                    def artifactory = Artifactory.server('ovn-rel-artifactory')
                    def buildInfo = Artifactory.newBuildInfo()
                    buildInfo.env.capture = true
                    def uploadSpec =
                            """{"files":
		                             [{"pattern": "target/universal/*.tgz",
		                               "target": "ovn-releases",
		                               "recursive": "false"}]
		                           }"""
                    artifactory.upload(uploadSpec, buildInfo)
                    artifactory.publishBuildInfo(buildInfo)
                }
            }
          }

        stage ('ovn_clearing_jobs release build') {
            when {
                expression { PTYPE ==~ /(library)/ }
                expression { REPONAME ==~ /(OVN_CLEARING_JOBS|OVN_CLEARING_XDC_SYNC|OVN_RIAK_PERSISTENCE)/ }
                anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
            }
            steps {
                build job: "OVN-OP/ovn_clearing_jobs/${env.BRANCH_NAME}", parameters: [
                    booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                ]
            }
        }
        stage ('ovn_clearing_xdc_sync release build') {
            when {
                expression { PTYPE ==~ /(library)/ }
                expression { REPONAME ==~ /(OVN_CLEARING_JOBS|OVN_CLEARING_XDC_SYNC|OVN_RIAK_PERSISTENCE)/ }
                anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
            }
            steps {
                build job: "OVN-OP/ovn_clearing_xdc_sync/${env.BRANCH_NAME}", parameters: [
                    booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                ]
            }
        }
        stage ('ovn_riak_persisitence release build') {
            when {
                expression { PTYPE ==~ /(library)/ }
                expression { REPONAME ==~ /(OVN_CLEARING_JOBS|OVN_CLEARING_XDC_SYNC)/ }
                anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
            }
            steps {
                build job: "OVN-OP/ovn_riak_persisitence/${env.BRANCH_NAME}", parameters: [
                    booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                    ]
                }
            }
        }
        post {
        failure {
            script {
                if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME =~ 'epic-') {
                    def committer_email = readFile('.git/committer-email').trim()
                    mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. More info at ${BUILD_URL}\nTrack: CLEARING \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}",
                            subject: "${JOB_NAME} job: Build failed",
                            to: "${committer_email}, NAOVNClearingTrack@visa.com"
                } else {
                    def committer_email = readFile('.git/committer-email').trim()
                    mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. More info at ${BUILD_URL}\nTrack: CLEARING \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}",
                            subject: "${JOB_NAME} job: Build failed",
                            to: "${committer_email}"
                    }
                }
            }
          }
        }
    }
