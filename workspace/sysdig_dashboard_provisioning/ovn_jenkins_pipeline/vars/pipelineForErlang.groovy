//
// Shared library to define different declarative pipelines depending on
// the language: Er
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline
// To use this library, invoke it by calling the filename providing the corresponding parameter.
// - ptype : 'service' | 'library'
// - reponame : Name of library repository name in upper case. This parameter is mandatory for ptype 'library'

def call(String ptype, String reponame=null) {

        // Description: This pipeline is designed to build and release Erlang applications.

        pipeline {

            agent {
                docker {
                    image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
                    label 'ovn_build'
                    args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh'
                }
            }

            parameters {
                booleanParam(name: 'BUILD_AND_PUBLISH', defaultValue: false, description: 'Do you want to build and publish the artifact?')
            }

            environment {
                PTYPE = "${ptype}"
                REPONAME = "${reponame}"
            }

            options { timeout(time: 2, unit: 'HOURS') }

            stages {

                stage('Pull latest dependencies') {
                    when { anyOf { branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    steps { sh 'make deps' }
                }

                stage('Pull frozen dependencies') {
                    when { branch 'release-*' }
                    environment {
                        PACKAGES_MK = '.frozen.packages.mk'
                        PKG_FILE2 = '.frozen.packages'
                    }
                    steps { sh 'make deps' }
                }

                stage('Build application') {
                    steps { sh "make app" }
                }

                stage('Unit testing') {
                    when { anyOf { branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    environment {
                        COVER = '1'
                    }
                    steps {
                        sh 'make tests'
                        sh 'make all.coverdata'
                        sh 'covertool -cover all.coverdata -output test/coverage.xml -src src'
                    }
                }

                stage('Syntax checker') {
                    when { anyOf { branch 'master'; branch 'epic-*';branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    steps { sh 'make elvis' }
                }

                stage('Acceptance testing') {
                    when { anyOf { branch 'feature/OVN-*'; branch 'epic-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    steps { ansiColor('xterm') { echo "\u001B[31mThe Acceptance Test step for this jenkinsfile is TBD\u001B[m" } }
                }

                stage('Dialyzer') {
                    when { anyOf { branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    steps {
                        sh 'mkdir -p deps/ovn/ebin'
                        sh 'make plt || : echo "ok to fail plt generation"'
                        sh 'make dialyze || echo "ok to fail for now"'
                        sh 'rm -rf deps/ovn'
                    }
                }

                stage('Report generation') {
                    when { anyOf { branch 'master'; branch 'epic-*'; branch 'feature/OVN-*'; branch 'bugfix/OVN-*'; branch 'PR-*' } }
                    steps {

                        // erlang compiler warnings check
                        warnings canComputeNew: false,
                        canResolveRelativePaths: false,
                        categoriesPattern: '',
                        consoleParsers: [[parserName: 'Erlang Compiler (erlc)']],
                        defaultEncoding: '',
                        excludePattern: '',
                        healthy: '',
                        includePattern: '',
                        messagesPattern: '',
                        unHealthy: ''

                        // publish Common test
                        publishHTML([allowMissing: true,
                                     alwaysLinkToLastBuild: true,
                                     keepAll: true,
                                     reportDir: 'logs',
                                     reportFiles: 'index.html',
                                     reportName: 'Common Tests Report',
                                     reportTitles: ''])

                        // Cobertura Coverage publisher
                        step([$class: 'CoberturaPublisher',
                              autoUpdateHealth: false,
                              autoUpdateStability: false,
                              coberturaReportFile: 'test/coverage.xml',
                              failUnhealthy: false,
                              failUnstable: false,
                              maxNumberOfBuilds: 0,
                              onlyStable: false,
                              sourceEncoding: 'ASCII',
                              zoomCoverageChart: false])

                    }
                }

                stage('Build release package') {
                    when {
                        expression { PTYPE ==~ /(service)/ }
                        anyOf {
                            allOf { branch 'release-*'; expression { return params.BUILD_AND_PUBLISH }};
                            branch 'master';
                            branch 'epic-*';
                        }
                    }

                    environment {
                        RELX_CONFIG = 'relx.config'
                        RELX_OPTS = 'tar'
                    }

                    steps {
                        sh '''
                        make relx-rel
                        for i in _rel/*/*.tar.gz; do mv "$i" "${i%.tar*}-${BRANCH_NAME}-build${BUILD_ID}".tar.gz; done
                        '''
                        archiveArtifacts artifacts: '_rel/*/*.tar.gz', fingerprint: true
                    }
                }

                stage('Publish to ovngit') {
                    when {
                        expression { PTYPE ==~ /(service)/ }
                        anyOf {
                            allOf{ branch 'release-*'; expression { return params.BUILD_AND_PUBLISH }};
                            branch 'master';
                            branch 'epic-*';
                        }
                    }

                    steps {
                    sh 'curl -s -f -O http://sl55ovnapq01.visa.com/git/@pod1/publish-scripts/v0.1.1:/publish-artifact.sh'
                    sh 'chmod +x ./publish-artifact.sh'
                    sh './publish-artifact.sh'
                    archiveArtifacts artifacts: 'project_*.packages*', fingerprint: true
                    archiveArtifacts artifacts: 'ovngit.ref', fingerprint: true
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
                                     [{"pattern": "_rel/*/*.tar.gz",
                                       "target": "ovn-app-temp-el7",
                                       "recursive": "false"}]
                                   }"""
                            artifactory.upload(uploadSpec,buildInfo)
                            artifactory.publishBuildInfo(buildInfo)
                        }
                    }
                }

                stage('Publish RELEASE to Artifactory') {
                    when {
                        expression { PTYPE ==~ /(service)/ }
                        allOf{ branch 'release-*'; expression { return params.BUILD_AND_PUBLISH }}
                    }

                    steps {
                        script {
                            def artifactory = Artifactory.server('ovn-artifactory')
                            def buildInfo = Artifactory.newBuildInfo()
                            buildInfo.env.capture = true
                            def uploadSpec =
                                """{"files":
                                     [{"pattern": "_rel/*/*.tar.gz",
                                       "target": "ovn-app-el7",
                                        "recursive": "false"}]
                                   }"""
                            artifactory.upload(uploadSpec,buildInfo)
                            artifactory.publishBuildInfo(buildInfo)
                        }
                    }
                }

                stage('Publish RELEASE to OVN-Releases Artifactory') {
                    when { branch 'release-*' }
                    steps {
                        script {
                            def artifactory = Artifactory.server('ovn-rel-artifactory')
                            def buildInfo = Artifactory.newBuildInfo()
                            buildInfo.env.capture = true
                            def uploadSpec =
                                    """{"files":
		                             [{"pattern": "_rel/*/*.tar.gz",
		                               "target": "ovn-releases",
		                               "recursive": "false"}]
		                           }"""
                            artifactory.upload(uploadSpec,buildInfo)
                            artifactory.publishBuildInfo(buildInfo)
                        }
                    }
                }
                stage ('Mediator release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVNC|OVN_ACCEPTOR|OVN_ADVICE|OVN_ADVICE_CLIENT|OVN_COMMON|OVN_CONSOLE|OVN_HEALTHCHECK|OVN_LOG|OVN_OPDB|OVN-PROFILE|OVN_RULES|OVN_SWITCH_CLIENT|OVN_TEST_COMMON|OVN_YOKE|VISA_8583)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_mediator/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
                stage ('Switch release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVNC|OVN_ACCEPTOR|OVN_ADVICE_CLIENT|OVN_COMMON|OVN_CURRENCY_GEN|OVN_HEALTHCHECK|OVN_LOG|OVN_MEDIATOR_CLIENT|OVN_OPDB|OVN-PROFILE|OVN_RULES|OVN_TEST_COMMON|OVN_UMF|OVN_YOKE|VISA_8583)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_switch/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
                stage ('UMF Delivery release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVN_COMMON|OVN_HEALTHCHECK|OVN_LOG|OVN_OPDB|OVN-PROFILE|OVN_RULES|OVN_TEST_COMMON|OVN_UMF|VISA_8583)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_umf_delivery/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
                stage ('Vitalsigns Delivery release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVNC|OVN_COMMON|OVN_HEALTHCHECK|OVN_LOG|OVN_OPDB|OVN-PROFILE|OVN_RULES|OVN_TESTING_TOOLKIT_ERL|OVN_TEST_COMMON|OVN_UMF|VISA_8583)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_vitalsigns_delivery/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
                stage ('Multidc Sync release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVN_COMMON|OVN_HEALTHCHECK|OVN_LOG|OVN_OPDB)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_multidc_sync/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
                stage ('VIP EF Sync release build') {
                    when {
                        expression { PTYPE ==~ /(library)/ }
                        expression { REPONAME ==~ /(OVN_COMMON|OVN_HEALTHCHECK|OVN_LOG|OVN-PROFILE|OVN_SWITCH_CLIENT|OVN_UMF|OVN_YOKE|VISA_8583)/ }
                        anyOf { branch 'master'; branch 'release-*'; branch 'epic-*' }
                    }
                    steps {
                        build job: "OVN-OP/ovn_vip_ef_sync/${env.BRANCH_NAME}", parameters: [
                            booleanParam(name: 'BUILD_AND_PUBLISH', value: true)
                        ]
                    }
                }
            }

            post {
                failure {
                    script {
                        if ( env.BRANCH_NAME == 'master' || env.BRANCH_NAME =~ 'epic-' ) {
                            def committer_email = readFile('.git/committer-email').trim()
                            mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. \n More info at ${BUILD_URL} \nTrack: AUTH \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}",
                            subject: "${JOB_NAME} job: Build failed",
                            to: "${committer_email}, NAOVNAuthTrack@visa.com"
                        }
                        else {
                            def committer_email = readFile('.git/committer-email').trim()
                            mail body: "${JOB_NAME} build number ${BUILD_NUMBER} was unsuccessful. \n More info at ${BUILD_URL} \nTrack: AUTH \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}",
                            subject: "${JOB_NAME} job: Build failed",
                            to: "${committer_email}"
                        }
                    }
                }
            }
        }
    }
