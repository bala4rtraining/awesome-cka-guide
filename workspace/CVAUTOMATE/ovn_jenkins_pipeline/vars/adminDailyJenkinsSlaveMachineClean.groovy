//
// Description:    Shared library for all Jenkins slave machines to do housekeeping by
//                 removing PR workspace older than 60 days, stopped containers and docker images
//                 without at least one container associated to them. Job will be skipped
//                 if the current disk usage is lower than 50% (see $PRE_SET_USAGE_THRESHOLD below).
//                 If disk usage is above 80% even after housekeeping, an urgent notification will
//                 be sent to the General channel of OVN DevOps Team (Foster City) in Microsoft Teams.
//
// Job maintainer: NAOVNDEVOPS@visa.com
//

def call(String nodeID) {
  pipeline {
    agent {
        label "${nodeID}"
    }
    environment {
        HOUSE_KEEPING_PATH = "/opt/app"
        DISK_USAGE_BEFORE_CLEANING = sh(script: "df -h | grep $HOUSE_KEEPING_PATH | awk '{print \$5}' | head -n 1", returnStdout: true).trim()
        DOCKER_CONTAINER_TTL = 24
        HOST_NAME = sh(script: "echo \$HOSTNAME | cut -d'.' -f1", returnStdout: true).trim()
        PRE_SET_USAGE_THRESHOLD = 30
        WORKSPACE_DIRECTORY_TTL = 21
        BLUE='\033[0;34m'
        NC='\033[0m'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }
    stages {
       stage('Prepare') {
           steps {
               ansiColor('xterm') {
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                    echo "Auto housekeeping on Jenkins slave machine, triggered by the admin pipeline everyday"
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
               }
            }
       }
       stage('Stop container runs long than predefined ttl ') {
           steps {
               ansiColor('xterm') {
                   sh '''
                    echo "Stopping long-lived containers..."
                    sh jenkins-sh/stop_docker_after_x_hours.sh $DOCKER_CONTAINER_TTL
                   '''
               }
            }
       }
       stage('Housekeeping - Cleaning Docker images and mounted volumes') {
            steps {
              script {
                    sh '''
                      if ((${DISK_USAGE_BEFORE_CLEANING%?} > $PRE_SET_USAGE_THRESHOLD)); then
                          echo "Cleaning Docker dangling images and mounted volumes..."
                          docker system prune --force --volumes
                          echo "Cleaning unused Docker images (images begin with ovn-docker.artifactory.trusted.visa.com and also tagged as latest/stable are protected)."
                          docker images --filter=reference='ovn-docker.artifactory.trusted.visa.com/*'| grep -E -- 'latest|stable' | awk '{print $3}' > protected_image_id_list.log
                          docker images -aq > all_image_id_list.log
                          docker rmi $(grep -v -f protected_image_id_list.log all_image_id_list.log) || true
                          rm all_image_id_list.log protected_image_id_list.log
                          echo "After cleaning docker images and mounted volumes, the disk usage is $(df -h | grep $HOUSE_KEEPING_PATH | awk '{print $5}' | head -n 1)";
                      else
                          echo "The current disk usage is below our usage threshold $PRE_SET_USAGE_THRESHOLD%, docker image housekeeping on $HOST_NAME will be skipped";
                      fi
                      '''
                    }
                }
            }
        stage('Housekeeping - Removing old workspace directories') {
            steps {
                script {
                    sh '''
                    OVN_WORKSPACE_CLEANUP_DIR_LIST=cleanup-rmdir-list.txt
                    OVN_MASTER_WORKSPACE_SKIPPED=skipped-dir-list.txt
 
                      if ((${DISK_USAGE_BEFORE_CLEANING%?} > $PRE_SET_USAGE_THRESHOLD)); then
                          echo "Deleting old workspace directories"
                          echo "Finding workspace PR directories that are $WORKSPACE_DIRECTORY_TTL + days old under opt/app/jenkins/workspace ..."
                          find /opt/app/jenkins/workspace/*PR-*/ -maxdepth 0 -type d -mtime +$WORKSPACE_DIRECTORY_TTL | xargs ls -ld --full-time | awk '{print $9}' > $OVN_WORKSPACE_CLEANUP_DIR_LIST
                          echo "Finding workspace PR directories that are $WORKSPACE_DIRECTORY_TTL + days old under opt/app/jenkins/OVN/ ..."
                          find /opt/app/jenkins/OVN/OVN_dev/OVN-OP/*/PR-*/ -maxdepth 0 -type d -mtime +$WORKSPACE_DIRECTORY_TTL | xargs ls -ld --full-time | awk '{print $9}' >> $OVN_WORKSPACE_CLEANUP_DIR_LIST
                          echo "Finding cached go dependency workspace in the master build directories that are $WORKSPACE_DIRECTORY_TTL + days old and keep atleast on master build artifact..."
                          for dir in $(ls -d /opt/app/jenkins/OVN/OVN_dev/OVN-OP/*); do 
                            if [ -z "$(find $dir/master/*/.go/ -maxdepth 0 -type d -mtime -$WORKSPACE_DIRECTORY_TTL)" ]; then
                                find $dir/master/*/.go/ -maxdepth 0 -type d | sort -k1 | head -n -1 >> $OVN_WORKSPACE_CLEANUP_DIR_LIST
                                find $dir/master/*/.go/ -maxdepth 0 -type d | sort -r | head -n 1 >> $OVN_MASTER_WORKSPACE_SKIPPED
                            else
                                find $dir/master/*/.go/ -maxdepth 0 -type d -mtime +$WORKSPACE_DIRECTORY_TTL >> $OVN_WORKSPACE_CLEANUP_DIR_LIST
                                find $dir/master/*/.go/ -maxdepth 0 -type d -mtime -$WORKSPACE_DIRECTORY_TTL >> $OVN_MASTER_WORKSPACE_SKIPPED
                            fi
                          done

                          while read dir_path; do
                            if [[ $dir_path != "." ]]; then
                              echo "Deleting $dir_path.."
                              chmod -R 777 $dir_path || echo "Having problems when changing the permission of $dir_path, step skipped"
                              rm -rf $dir_path
                              echo "$dir_path deleted"
                            fi;
                          done < $OVN_WORKSPACE_CLEANUP_DIR_LIST

                          echo "${BLUE}[INFO]${NC} Keeping below workspace directory, as it is the latest master build."
                          cat $OVN_MASTER_WORKSPACE_SKIPPED

                          echo "After cleaning the older workspace directories, the disk usage is $(df -h | grep $HOUSE_KEEPING_PATH | awk '{print $5}' | head -n 1)";
                      else
                          echo "The current disk usage is below our usage threshold $PRE_SET_USAGE_THRESHOLD%, old directories housekeeping on $HOST_NAME will be skipped";
                      fi
                    '''
                }
            }

        }
        stage('Changing Jenkins customize description') {
            environment {
                DISK_USAGE_AFTER_CLEANING = sh(script: "df -h | grep $HOUSE_KEEPING_PATH | awk '{print \$5}'", returnStdout: true).trim()
            }
            steps {
                script {
                    currentBuild.description = "$HOST_NAME: $HOUSE_KEEPING_PATH $DISK_USAGE_BEFORE_CLEANING => $DISK_USAGE_AFTER_CLEANING"
                }
            }
        }
        stage('Post-housekeeping capacity check') {
            steps {
                script {
                    HIGH_USAGE_THRESHOLD = 80
                    POST_CLEAN_PATH_USAGE = sh(script: "df -h | grep $HOUSE_KEEPING_PATH | awk '{print \$5}' | head -n 1", returnStdout: true).trim()
                    if (POST_CLEAN_PATH_USAGE.substring(0, POST_CLEAN_PATH_USAGE.length() - 1).toInteger() > HIGH_USAGE_THRESHOLD) {
                        mail body: "Disk usage of ${env.HOST_NAME} is at ${POST_CLEAN_PATH_USAGE} and has exceeded the high-usage threshold of ${HIGH_USAGE_THRESHOLD}%. \
                        Please fix accordingly to avoid jamming the build pipeline.",
                        subject: "[URGENT] Disk usage of ${env.HOST_NAME} has exceeded ${HIGH_USAGE_THRESHOLD}% [URGENT]",
                        from: "OVN Admin Job Jenkins <noreply@visa.com>",
                        to: "9afcdadf.visainc.onmicrosoft.com@amer.teams.ms"
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        failure {
            script {
                CURRENT_JOB_NAME = sh(script: "echo $JOB_NAME", returnStdout: true).trim()
                ADMIN_JOB_LIST = "Administration_Jobs"

                if (CURRENT_JOB_NAME.split('/')[2] == ADMIN_JOB_LIST) {
                    mail body: "Failed on performing daily Jenkins server disk usage cleanup. \n Please check Jenkins_URL for more information: ${env.BUILD_URL}",
                    subject: "[Failed] Daily Jenkins Server Disk Housekeeping Failed - ${env.HOST_NAME} [Failed]",
                    from: "OVN Admin Job Jenkins <noreply@visa.com>",
                    to: "NAOVNDEVOPS@visa.com"
                } else {
                    sh '''
                    echo " *** Developer testing CI job, build failure email notification has been disabled *** "
                    '''
                }
            }
            
        }
    }
  }
}
