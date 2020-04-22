//
// Shared library to define different declarative pipelines depending on
// the language: GoLang.
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline
// MODULENAME : indicate the name of the import package for the repository e.g importname for ovn-commons is commons
// SonarqubeID : stands for the unique project key in sonarqube server for each repository.
// RepoType : stands for the type of repository passed (ie. 'library' or 'service' )
// GoProxy : stands for ENV variable GOPROXY passed(ie. 'ovn-go-virtual-plusdev'). Default value: 'ovn-go-virtual'

def call(Map configParams) {
    // params.SonarqubeID
    // configParams.RepoType
    // configParams.GoProxy
    // Description: This pipeline is designed to build and release Golang applications.

  pipeline {
    agent {
        docker {
            image 'ovn-docker.artifactory.trusted.visa.com/centos7_gobuild:stable'
            label 'ovn_build'
            args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh -v /var/run/docker.sock:/var/run/docker.sock'
            customWorkspace "${env.JOB_NAME}/${env.BUILD_ID}"
          }
        }

    options {
        ansiColor('xterm-256color')
        timeout(time: 1, unit: 'HOURS')
    }

    parameters {
        booleanParam(name: 'PUBLISH_MODULE', defaultValue: false, description: 'Do you want to publish the module?')
        booleanParam(name: 'RUN_BD_SCAN', defaultValue: false, description: 'Do you want to run Blackduck scan?')
    }
    environment {
        GOPATH = "$WORKSPACE/.go"
        MODULENAME = sh(script: '''sed -n 's/^module[ ]*\\([^ ]*\\)/\\1/p' go.mod''', returnStdout: true).trim()
        PACKAGE_DIR = "$GOPATH/src/${MODULENAME}"
        REPONAME = sh(script: '''basename -s .git `git config --get remote.origin.url`''', returnStdout: true).trim()
        TAG_VERSION=sh(script: '''git describe --match "v[0-9]*.[0-9]*.[0-9]*" --exclude "*-*" --abbrev=0 --tags $(git rev-list --tags --max-count=1) ||echo "v0.0.0"''' , returnStdout: true).trim()
        GO111MODULE = "on"
        GOSUMDB="off"
        GOFLAGS="-mod=readonly"
        ARTIFACTORY_CREDS_DEV = credentials('svcnpovndev_id')
        ARTIFACTORY_CREDS_PROD = credentials('svcnpovnprd_id')
        SONARQUBE_KEY = credentials('ovn_sonarqube')
        GOPROXY="https://artifactory.trusted.visa.com/api/go/${configParams.GoProxy ?: "ovn-go-virtual"}"
        ARTIFACTORY_URL="https://artifactory.trusted.visa.com"
        GO_DEV_REPO="ovn-go-dev"
        GO_PROD_REPO="ovn-go-prod"
        REPOSITORY_TYPE="${configParams.RepoType}"
        HUB_LOG_LEVEL = 'INFO'
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        BLUE='\033[0;34m'
        NC='\033[0m'
        CLOUDVIEW_CREDS = credentials('cloudview')
      }
    stages {
      stage('GOPROXY overide') {
            when { branch 'release-*' }
            environment {
                GOPROXY = "https://artifactory.trusted.visa.com/api/go/${configParams.GoProxy ?: "ovn-go-virtual-prod"}"

            }
            steps { sh 'echo $GOPROXY' }
      }
      stage('prepare') {
          steps {
            // 1. setting up GOPATH structure, since we do not have a src/visa.com prefix inside of our repo
            // 2. fetching dependencies with glide
            sh '''
              git show -s --pretty=%ce > .git/committer-email
              go version
              rm -rf $PACKAGE_DIR
              mkdir -p $PACKAGE_DIR
              cp -r * $PACKAGE_DIR
              cd $PACKAGE_DIR
              '''
          }
        }

      stage('Golang Static code analysis'){
        steps {
            sh '''
              golangci-lint run --out-format checkstyle --skip-dirs "vendor" --exclude "could not import*" --disable-all --enable=typecheck \
              --enable=deadcode  --enable=gocyclo --enable=golint --enable=varcheck --enable=structcheck --enable=maligned \
              --enable=megacheck --enable=staticcheck --enable=ineffassign --enable=interfacer --enable=unconvert \
              --enable=goconst --enable=gosec --enable=lll --enable=dupl --enable=goimports --enable=unparam \
              --enable=nakedret --enable=prealloc --enable=scopelint --enable=funlen --enable=misspell --enable=gosimple --enable=gofmt \
              --enable=depguard --enable=dogsled --enable=gocritic --enable=gochecknoinits --enable=gochecknoglobals --enable=godox \
              --enable=govet --enable=unused ./... >$WORKSPACE/checkstyle.xml || echo $?
              '''
            checkstyle canRunOnFailed: true, defaultEncoding: '', healthy: '', pattern: 'checkstyle.xml', unHealthy: ''
          }
        }

      stage('custom build step') {
          when {expression { REPOSITORY_TYPE ==~ /(custom)/ }}
          steps{
            script {
                    configParams.CustomBuildSteps()
                  }
                }
              }

      stage('unit test with race condition') {
           when {
           expression { REPOSITORY_TYPE != 'custom'  }
           }
           steps {
                script {
                    try {
                        sh '''
                            go version
                            mkfifo pipe
                            tee test.out < pipe &
                            make test > pipe
                        '''
                    } catch (caughtError) {
                       error("Test Failures")
                    } finally {
                        sh '''
                            rm -rf report.xml
                            cat test.out | go-junit-report > report.xml
                        '''
                        junit 'report.xml'
                    }
                }
            }
        }


        stage('Generate Coverage') {
            when {
            expression { REPOSITORY_TYPE != 'custom' }
            anyOf { branch 'master'; branch 'epic-*'; branch 'feature/OVNLTA-*'; branch 'bugfix/OVNLTA-*'; branch 'PR-*' }
            }
            steps {
                sh '''
        go version
        make cover
        gc-cober < coverage.out > coverage.xml
        '''

                // publish Common test
                publishHTML([allowMissing: true,
                             alwaysLinkToLastBuild: true,
                             keepAll: true,
                             reportDir: 'logs',
                             reportFiles: 'coverage.html',
                             reportName: 'Common Tests Report',
                             reportTitles: ''])

                // Cobertura Coverage publisher
                step([$class: 'CoberturaPublisher',
                      autoUpdateHealth: false,
                      autoUpdateStability: false,
                      coberturaReportFile: 'coverage.xml',
                      failUnhealthy: false,
                      failUnstable: false,
                      maxNumberOfBuilds: 0,
                      onlyStable: false,
                      sourceEncoding: 'ASCII',
                      zoomCoverageChart: false])
            }
        }
        stage('Sonar Analysis') {
            when { not { branch 'PR-*' } }
            steps{
                script{
                    def scannerHome = tool 'Sonar Scanner 3.1';
                    withSonarQubeEnv('Visa Sonar') {
                    sh """
                   ${scannerHome}/bin/sonar-scanner \
                      -Dsonar.login=$SONARQUBE_KEY \
                      -Dsonar.branch.name=$BRANCH_NAME
                    """
                    }
                }
            }
        }

        stage('Sonar Analysis on PR') {
            when { branch 'PR-*' }
            steps{
                script{
                    def scannerHome = tool 'Sonar Scanner 3.1';
                    withSonarQubeEnv('Visa Sonar') {
                    sh """
                   ${scannerHome}/bin/sonar-scanner \
                      -Dsonar.login=$SONARQUBE_KEY \
                      -Dsonar.pullrequest.branch=$CHANGE_BRANCH \
                      -Dsonar.pullrequest.base=$CHANGE_TARGET \
                      -Dsonar.pullrequest.key=$CHANGE_ID
                    """
                    }
                }
                script {
                    timeout(time: 120, unit: 'SECONDS') {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Pipeline aborted due to SonarQube Quality Gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Blackduck Scan') {
            when {
                expression { return params.RUN_BD_SCAN }
            }
            steps {
                sh'''
                go mod vendor
                cd vendor && rm -rf visa.com
                export BLACKDUCK_SKIP_PHONE_HOME='true'
                '''
                hub_scan bomUpdateMaximumWaitTime: '5', cleanupOnSuccessfulScan: true, codeLocationName: '', deletePreviousCodeLocations: false, dryRun: false, excludePatterns: [[exclusionPattern: '']], hubProjectName: "OVN_${REPONAME}_AskNowId_0030023", hubProjectVersion: "${GIT_BRANCH}", hubVersionDist: 'EXTERNAL', hubVersionPhase: 'PLANNING', projectLevelAdjustments: true, scanMemory: '8192', scans: [[scanTarget:"vendor"]], shouldGenerateHubReport: true, unmapPreviousCodeLocations: false
            }
        }
        stage('Publish MODULE to Artifactory') {
            when {
                expression { REPOSITORY_TYPE ==~ /(library)/ }
                anyOf {branch 'master'; buildingTag(); expression { return params.PUBLISH_MODULE } }
            }
            steps {
              script{
                if(env.BRANCH_NAME == 'master'){
                  stage('Publishing snapshot from master branch'){
                    sh '''
                      cd $PACKAGE_DIR
                      jfrog rt config --url=https://artifactory.trusted.visa.com --user=$ARTIFACTORY_CREDS_DEV_USR --password=$ARTIFACTORY_CREDS_DEV_PSW --interactive=false
                      COMMITED_DATE=$(git rev-list --format=format:'%cd' --date=local --max-count=1 `git rev-parse HEAD` | sed -n 2p)
                      FORMATTED_COMMITED_DATE=$(date -u +"%Y%m%d%H%M%S" --date "$COMMITED_DATE")
                      SHORT_HASH=$(git rev-parse --short=12 HEAD)
                      TAG_VERSION=$(awk 'BEGIN { FS="." } { $3++;} { printf "v%d.%d.%d", $1, $2, $3 }' <<< $TAG_VERSION)
                      VERSION_NUMBER="${TAG_VERSION}-0.${FORMATTED_COMMITED_DATE}-${SHORT_HASH}"
                      echo $VERSION_NUMBER
                      BUILD_NAME='jenkins-'$(tr '/' '-' <<<${JOB_NAME})
                      jfrog rt go-publish ${GO_DEV_REPO} ${VERSION_NUMBER} --build-name="${BUILD_NAME}" --build-number=${BUILD_NUMBER}
                      jfrog rt build-add-git ${BUILD_NAME} ${BUILD_NUMBER}
                      jfrog rt build-publish ${BUILD_NAME} ${BUILD_NUMBER} --build-url="${BUILD_URL}"
                      '''
                  }
                }
                else if (env.TAG_NAME != null) {
                  stage('Publishing Go Module with new tag') {
                    sh '''
                      ARTIFACTORY_PACKAGE_META_DATA=artifactory_package_meta_data.json
                      TAG_NAME_JSON="${TAG_NAME}"
                      TAG_NAME_JSON="$TAG_NAME_JSON" jq -n 'env.TAG_NAME_JSON'
                      jfrog rt config --url=https://artifactory.trusted.visa.com --user=$ARTIFACTORY_CREDS_PROD_USR --password=$ARTIFACTORY_CREDS_PROD_PSW --interactive=false
                      jfrog rt s ${GO_PROD_REPO}/${MODULENAME}/@v/ > $ARTIFACTORY_PACKAGE_META_DATA
                      IS_VERSION_DUPLICATE=$(cat $ARTIFACTORY_PACKAGE_META_DATA| jq -r --arg TAG_NAME_JSON "$TAG_NAME_JSON" '[.[] | select(.props."go.version"==[$TAG_NAME_JSON])][0] | length')
                      VERSION_NUMBER="${TAG_NAME}"
                      LOGGING_FORMAT_GUIDE_LINK="https://visawiki.trusted.visa.com/display/OVN/CHANGELOG.md+Logging+Format+Guide"
                      CURRENT_RELEASE="v0"

                      echo "${BLUE}[INFO]${NC} Checking release tag logical sequence based on tagged commit date."
                      sh jenkins-sh/check_git_tag_logical_sequence.sh $VERSION_NUMBER
                      if (($IS_VERSION_DUPLICATE == 0)); then
                        cd $PACKAGE_DIR
                        echo $VERSION_NUMBER
                        if [[ "$VERSION_NUMBER" =~ ^v[0-9]{1,2}\\.[0-9]{1,3}\\.[0-9]{1,3}$ ]]; then
                          echo "${BLUE}[INFO]${NC} Checking if tag version major digit is different than the currently release."
                          if [[ ${VERSION_NUMBER%%.*} == $CURRENT_RELEASE ]]; then

                            if [[ ! -e ./CHANGELOG.md ]]; then
                              echo -e "${RED}[ERROR]${NC} CHANGELOG.md is missing from repo directory."
                              echo "deleting tag: ${TAG_NAME}"
                              curl -s -X DELETE -H "Authorization: Bearer ${BITBUCKET_API_TOKEN}" -H "Content-Type: application/json" https://stash.trusted.visa.com:7990/rest/git/1.0/projects/OP/repos/${REPONAME}/tags/${TAG_NAME}
                              exit 1
                            else
                              echo "Checking CHANGELOG.md logging format..."
                              RELEASE_TITLE=$(sed -n '1p' < CHANGELOG.md)
                              RELEASE_DESCRIPTION=$(sed -n '3p' < CHANGELOG.md)
                              if [[ $RELEASE_TITLE =~ ^#[[:space:]][v][0-9]{1,2}\\.[0-9]{1,3}\\.[0-9]{1,3} && $RELEASE_DESCRIPTION =~ ^### ]] ;then
                                echo -e "${BLUE}[INFO]${NC} CHANGELOG.md logging format is ${GREEN}OK${NC}."
                              else
                                echo -e "${RED}[ERROR]${NC} CHANGELOG.md will need additional description! For more information, please visit OVN logging format guide:  ${LOGGING_FORMAT_GUIDE_LINK}"
                                echo "deleting tag: ${TAG_NAME}"
                                curl -s -X DELETE -H "Authorization: Bearer ${BITBUCKET_API_TOKEN}" -H "Content-Type: application/json" https://stash.trusted.visa.com:7990/rest/git/1.0/projects/OP/repos/${REPONAME}/tags/${TAG_NAME}
                                exit 1
                              fi;
                            fi;
                            BUILD_NAME='jenkins-'$(tr '/' '-' <<<${JOB_NAME})
                            jfrog rt go-publish ${GO_PROD_REPO} ${VERSION_NUMBER} --build-name="${BUILD_NAME}" --build-number=${BUILD_NUMBER}
                            jfrog rt build-add-git ${BUILD_NAME} ${BUILD_NUMBER}
                            jfrog rt build-publish ${BUILD_NAME} ${BUILD_NUMBER} --build-url="${BUILD_URL}"
                            echo -e "${BLUE}[INFO]${NC} Published to the artifactory ${GREEN}successfully${NC}! "
                          else
                            echo -e "${RED}[ERROR]${NC} ${VERSION_NUMBER%%.*} is an invalid version major digit, will not publish to the artifactory."
                          fi;
                        else
                          echo -e "${RED}[ERROR]${NC} ${VERSION_NUMBER} is an invalid tag, will not publish to the artifactory."
                        fi;
                      else
                        echo -e "${YELLOW}[WARNING]${NC} ${VERSION_NUMBER} already exist(s), the publish step has been skipped. Check ${GO_PROD_REPO}/${MODULENAME}/@v/ for more information."
                      fi
                      '''
                  }
                }
                else if (params.PUBLISH_MODULE){
                  stage('Publishing snapshot'){
                    sh '''
                      cd $PACKAGE_DIR
                      jfrog rt config --url=https://artifactory.trusted.visa.com --user=$ARTIFACTORY_CREDS_DEV_USR --password=$ARTIFACTORY_CREDS_DEV_PSW --interactive=false
                      COMMITED_DATE=$(git rev-list --format=format:'%cd' --date=local --max-count=1 `git rev-parse HEAD` | sed -n 2p)
                      FORMATTED_COMMITED_DATE=$(date -u +"%Y%m%d%H%M%S" --date "$COMMITED_DATE")
                      SHORT_HASH=$(git rev-parse --short=12 HEAD)
                      VERSION_NUMBER="v0.0.0-${FORMATTED_COMMITED_DATE}-${SHORT_HASH}"
                      echo $VERSION_NUMBER
                      BUILD_NAME='jenkins-'$(tr '/' '-' <<<${JOB_NAME})
                      jfrog rt go-publish ${GO_DEV_REPO} ${VERSION_NUMBER} --build-name="${BUILD_NAME}" --build-number=${BUILD_NUMBER}
                      jfrog rt build-add-git ${BUILD_NAME} ${BUILD_NUMBER}
                      jfrog rt build-publish ${BUILD_NAME} ${BUILD_NUMBER} --build-url="${BUILD_URL}"
                      '''
                  }
                }
              }
            }
          }
          stage('Test Dockerfile') {
            when {
             allOf{
                branch 'PR-*'
                expression { REPOSITORY_TYPE ==~ /(service)/ }
                expression {return sh(returnStdout: true, script: 'git diff --name-only HEAD~1..HEAD | grep Dockerfile || exit 0')};
              }
            }
              steps {
                ansiColor('xterm') {
                  script {
                    sh '''
                    docker build -t test-image:tmp .
                    docker save test-image:tmp > test_image_tmp.tar
					dockle --debug --input test_image_tmp.tar > ${WORKSPACE}/test_image_tmp.json
					rm test_image_tmp.tar
					docker image rm test-image:tmp
                    docker image prune -f
                    '''
                  }
                }
              }
            }
          stage('Cloudview build trigger') {
            when {
              expression { REPOSITORY_TYPE ==~ /(service)/ }
              anyOf { branch 'master' }
            }
            steps {
              script {
                if (!fileExists('cloudview_project_repo_mapper.txt')) {
                  writeFile(file: 'cloudview_project_repo_mapper.txt', text: libraryResource('cloudview_project_repo_mapper.txt'))
                }
                sh '''
                if [ -z "$CLOUDPROJECT" ]
                then
                  echo "##########Cloudview build is skipped due to missing project key in cloudview_project_repo_mapper.txt##########"
                else
                  jfrog rt config --url=https://artifactory.trusted.visa.com --user=$ARTIFACTORY_CREDS_USR --password=$ARTIFACTORY_CREDS_PSW --interactive=false
                  jfrog rt dl "ovn-app-temp-el7/cvapi-*" --sort-by=created --sort-order=desc --limit=1
                  tar -C /tmp -xzf cvapi-*.tar.gz
                  chmod +x /tmp/bin/cvapi
                  PATH=$PATH:/tmp/bin
                  rm cvapi-*.tar.gz
                  CLOUDPROJECT=$(cat cloudview_project_repo_mapper.txt | grep $REPONAME | cut -d ":" -f 2)
                  echo "##########Cloudview build is triggered##########"
                  cvapi build -p $CLOUDPROJECT -b $BRANCH_NAME --username=$CLOUDVIEW_CREDS_USR --password=$CLOUDVIEW_CREDS_PSW --baseURL="https://build.trusted.visa.com:8443"
                fi
                '''
              }
            }
          }
        }
        post {
            success {
                script {
                    def committer_email = readFile('.git/committer-email').trim()
                    mail body: "project build success.\n More info at: ${env.BUILD_URL} \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}" ,
                            subject: "${JOB_NAME} build success" ,
                            to: "${committer_email}"
                    echo "\033[32m [BUILD SUCCESS] The build result has been notified to ${committer_email} \033[0m"

                if ((env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('epic-')) && configParams.skipcheckmarxscan != 'true') {
                    build job: 'OVN/OVN_dev/Administration_Jobs/checkmarx_scan_upload', parameters: [[$class: 'StringParameterValue', name: 'REPO_URL', value: "${env.GIT_URL}"]], wait: false
                } else {
                    echo "checkmarx-scan-upload builds are skipped due to if conditional"
                }
                if (env.BRANCH_NAME == 'master' ) {
                    build job: 'OVN/OVN_dev/Administration_Jobs/jenkins_jira_issue_tracker', parameters: [[$class: 'StringParameterValue', name: 'Jenkins_Status', value: "success"], [$class: 'StringParameterValue', name: 'Jenkins_Build_Url', value: "${env.BUILD_URL}"], [$class: 'StringParameterValue', name: 'Jenkins_Job_Name', value: "${JOB_NAME}"], [$class: 'StringParameterValue', name: 'Jenkins_Build_Id', value: "${env.BUILD_ID}"], [$class: 'StringParameterValue', name: 'Bitbucket_Git_Commit', value: "${GIT_COMMIT}"]], wait: false
                } else {
                    echo "jenkins-jira-issue-tracker builds are skipped due to if conditional"
                }
              }
            }
            failure {
                script {
                try{
                    def committer_email = readFile('.git/committer-email').trim()
                    mail body: "project build error is here: ${env.BUILD_URL} \nLast committer was: ${committer_email} \nCommit number: ${GIT_COMMIT}" ,
                            subject: "${JOB_NAME} job: Build failed",
                            to: "${committer_email}"
                    echo "\033[31m [BUILD FAILURE] The build result has been notified to ${committer_email} \033[0m"
                    }
                catch (err){
                    ansiColor('xterm-256color') {
                    mail body: "project build error is here: ${env.BUILD_URL} \n Build unsuccessful because of a possible issues in the agent block \n Please resolve issue or reach out to SCM team " ,
                        subject: "[AGENT BLOCK] ${JOB_NAME} job: Build failed",
                        to: "naovndevops@visa.com"
                    echo "\033[31m [BUILD FAILURE] The build result has been notified to the DevOps team. Please re-try after few minutes or reach to DevOps team. \033[0m"
                    }
                  }
                if (env.BRANCH_NAME == 'master') {
                      build job: 'OVN/OVN_dev/Administration_Jobs/jenkins_jira_issue_tracker', parameters: [[$class: 'StringParameterValue', name: 'Jenkins_Status', value: "failed"], [$class: 'StringParameterValue', name: 'Jenkins_Build_Url', value: "${env.BUILD_URL}"], [$class: 'StringParameterValue', name: 'Jenkins_Job_Name', value: "${JOB_NAME}"], [$class: 'StringParameterValue', name: 'Jenkins_Build_Id', value: "${env.BUILD_ID}"], [$class: 'StringParameterValue', name: 'Bitbucket_Git_Commit', value: "${GIT_COMMIT}"]], wait: false
                } else {
                  echo "jenkins-jira-issue-tracker build is skipped due to if conditional"
                }
            }
          }
        }
    }
}
