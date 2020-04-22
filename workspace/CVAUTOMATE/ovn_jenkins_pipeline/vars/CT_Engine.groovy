// Description:
// CT Engine, a shared library designed to support all continuous testing (CT) jobs.
// More information about CT could be found here: https://visawiki.trusted.visa.com/pages/viewpage.action?spaceKey=OVN&title=Continuous+Testing+%28CT%29+-+HLD
// 
// Required Parameters:
// TestComponent : Indicate the name of the component we are going to test.
// EnvironmentConfigPath : The path for the environment configration file used for cloud environment deployment.
// FeatureFile : The specific feature file and the version of the feature file repo (e.g CVV2.feature:v1.0.0)
// SubscriberEmail : Developer/GDL who will receive notification email report regarding to one CT job.

// TODO 1: Refactor the mediator IP address calculation to be shorter
// TODO 2: improve the success / fail. post items to include EMAIL notification
// TODO 3: When OVNB-3290 finished, remove the redundant "copy output.json file" logic by assigning the output path directly inside config.yaml

def call(Map configParams) {
    // configParams.TestComponent
    // configParams.EnvironmentConfigPath
    // configParams.FeatureFile
    // configParams.SubscriberEmail
    pipeline {
        agent {
            docker {
                image 'ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker'
                label 'ovn_build'
                args '-v /sys/fs/cgroup:/sys/fs/cgroup -v /home/was/.ssh:/home/was/.ssh -v /opt/app/ovnhub:/opt/app/ovnhub -v /var/run/docker.sock:/var/run/docker.sock'
                customWorkspace "${env.JOB_NAME}/${env.BUILD_ID}"
            }
        }
        options {
            ansiColor('xterm-256color')
            timeout(time: 1, unit: 'HOURS')
        }
        environment {
            TEST_COMPONENT = "${configParams.TestComponent}"
            ENVIRONMENT_CONFIG_PATH = "${configParams.EnvironmentConfigPath}"
            SUBSCRIBER_EMAIL = "${configParams.SubscriberEmail}"
            FEATURE_FILE_NAME = "${configParams.FeatureFile.split(':')[0]}"
            FEATURE_FILE_REPO_VERSION = "${configParams.FeatureFile.split(':')[1]}"
            ARTIFACTORY_URL = "https://artifactory.trusted.visa.com"
            ARTIFACTORY_CREDS = credentials('svcnpovndev_id')
            CLOUDVIEW_CREDS = credentials('cloudview')
            DEVOPSGDL = "NAOVNDEVOPS@visa.com"
            CONTAINER_WORKSPACE = "container_workspace" // a shared volume which contains all OVNTT container needed dependencies
            ROOT_DIR_WORKSPACE = "root_dir_workspace"   // an empty shared volume mounted to the ovntt root directory
            OVNTT_IMAGE_VERSION = "v0.0.0-361-30575e8"
        }
        stages {
            stage('Retrieving the Latest cvapi Tools') {
                steps {
                    script {
                        sh '''
                        echo "Getting the latest cvapi from artifactory..."
                        jfrog rt config --url=$ARTIFACTORY_URL --user=$ARTIFACTORY_CREDS_USR --password=$ARTIFACTORY_CREDS_PSW --interactive=false
                        jfrog rt dl "ovn-app-temp-el7/cvapi-*" --sort-by=created --sort-order=desc --limit=1
                        tar -C /tmp -xzf cvapi-*.tar.gz
                        chmod +x /tmp/bin/cvapi
                        echo "Successfully installed the cvapi"
                        '''
                    }
                }
            }
            stage('Building the Testing Environment on CloudView') {
                steps {
                    script {
                        sh '''
                        git clone ssh://git@stash.trusted.visa.com:7999/op/ovn_jenkins_pipeline.git
                        cd ovn_jenkins_pipeline
                        echo "Deploying testing environment defined in the deployment config yaml file..."
                        /tmp/bin/cvapi deploy --filepath $ENVIRONMENT_CONFIG_PATH --username=$CLOUDVIEW_CREDS_USR --password=$CLOUDVIEW_CREDS_PSW
                        cp environment.json $WORKSPACE
                        '''
                    }
                }
            }
            stage('Parsing Environment Snapshot') {
                steps {
                    script {
                        sh '''
                        echo "Getting the environment ID..."
                        ENVIRONMENT_ID=`jq -r '.id' <environment.json`

                        echo "Getting the environment snapshot using the environment ID"
                        /tmp/bin/cvapi snapshot --environmentId=$ENVIRONMENT_ID --username=$CLOUDVIEW_CREDS_USR --password=$CLOUDVIEW_CREDS_PSW
                        
                        echo "Getting OVN mediator IP from the environment snapshot..."
                        SNAPSHOT_FILE=snapshot_$ENVIRONMENT_ID.json
                        LEN=`jq '.Pods | length' < $SNAPSHOT_FILE`

                        for (( INDEX=$(($LEN - 1)); INDEX>=0; INDEX-- ))
                        do
                            pod_name=`jq --argjson i $INDEX  '.Pods[$i].podName' < $SNAPSHOT_FILE`
                            if [[ $pod_name =~ 'mediator' ]]
                            then
                                pod_ip=`jq --argjson i $INDEX '.Pods[$i].podIP' < $SNAPSHOT_FILE | tr -d '"'`
                                echo $pod_ip > mediator_ip_log
                                break
                            fi
                        done
                        '''
                    }
                }
            }
            stage('OVNTT Dependency Preparation') {
                steps {
                    script {
                        sh '''
                        echo "Creating shared volume between Jenkins VM workspace and the OVNTT container..."
                        mkdir $CONTAINER_WORKSPACE
                        mkdir $ROOT_DIR_WORKSPACE
                        cp mediator_ip_log $CONTAINER_WORKSPACE
                        mediator_ip=$(cat mediator_ip_log)
                        VOLUME_PATH=$WORKSPACE"/"$CONTAINER_WORKSPACE
                        cd $CONTAINER_WORKSPACE
                        echo "Getting Profile Database..."
                        jfrog rt config --url=$ARTIFACTORY_URL --user=$ARTIFACTORY_CREDS_USR --password=$ARTIFACTORY_CREDS_PSW --interactive=false
                        jfrog rt dl "ovn/ovn-tt-features/profile.db" --sort-by=created --sort-order=desc --limit=1
                        cd ovn-tt-features
                        cp profile.db $VOLUME_PATH
                        cd ..
                        rm -rf ovn-tt-features

                        echo "Getting OVNTT config file template..."
                        jfrog rt dl "ovn/ovn-tt-features/ovntt_config_template.yaml" --sort-by=created --sort-order=desc --limit=1
                        cd ovn-tt-features
                        cp ovntt_config_template.yaml $VOLUME_PATH
                        cd ..
                        
                        echo "Updating deployment environment mediator IP to the OVNTT config file template..."
                        sed 's/MEDIATOR_IP/'$mediator_ip:8050'/' ovntt_config_template.yaml > config.yaml

                        echo "Getting feature files.."
                        jfrog rt dl "ovn/ovn-tt-features/ovntt-feature-files-$FEATURE_FILE_REPO_VERSION.tar.gz" --sort-by=created --sort-order=desc --limit=1
                        cd ovn-tt-features
                        tar -C $VOLUME_PATH -xzf ovntt-feature-files-$FEATURE_FILE_REPO_VERSION.tar.gz

                        echo "Starting OVNTT container..."
                        ROOT_DIR_VOLUME_PATH=$WORKSPACE"/"$ROOT_DIR_WORKSPACE
                        docker volume create --driver local --opt type=none --opt device=$ROOT_DIR_VOLUME_PATH --opt o=bind root_dir_volume_$BUILD_NUMBER
                        docker run -v $VOLUME_PATH:/app/testing_toolkit/container_workspace -v root_dir_volume_$BUILD_NUMBER:/app/testing_toolkit ovn-docker.artifactory.trusted.visa.com/ovn_testing_toolkit:$OVNTT_IMAGE_VERSION --configFile $CONTAINER_WORKSPACE/config.yaml -feat=$CONTAINER_WORKSPACE/features/$FEATURE_FILE_NAME.feature -tag=smoke
                        cd $ROOT_DIR_VOLUME_PATH
                        cp $FEATURE_FILE_NAME".feature.json" ct_report.json
                        '''
                    }
                }
            }
            stage('Validating OVNTT Test Report') {
                steps {
                    script {
                        sh '''
                        echo "JSON format validator"
                        '''
                    }
                }
            }
            stage('Archive') {
                steps {
                    echo "Archiving..."
                    archiveArtifacts artifacts: 'container_workspace/ct_report.txt, root_dir_workspace/ct_report.json'
                }
            }
        }
        post {
            always {
                sh '''
                echo "Decommissioning the test environment..."
                ENVIRONMENT_ID=`jq -r '.id' <environment.json`
                /tmp/bin/cvapi decommission --environmentId=$ENVIRONMENT_ID --username=$CLOUDVIEW_CREDS_USR --password=$CLOUDVIEW_CREDS_PSW
                '''
            }
            success {
                script {
                    echo "successful"
                }
            }
            failure {
                script {
                    echo "failure..."
                }
            }
        }
    }
}
