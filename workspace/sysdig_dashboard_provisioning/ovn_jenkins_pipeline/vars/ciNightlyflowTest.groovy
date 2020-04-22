//
// Shared library to define ci nitghtly auth declarative pipelines
// More information about declarative pipelines here: https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline
//
// To use this library, invoke it by calling the filename providing the corresponding hostnames. e.g. ciNightlyFlowTest('mediator_dc1_ip', 'mediator_dc2_ip', 'umf_broker_dc1_ip')
//
def call(String flow, String mediator_dc1_ip, String mediator_dc2_ip, String umf_broker_dc1_ip){
if (flow == 'authTest'){

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
    parameters {
        booleanParam(defaultValue: true, description: '', name: 'ActiveActive_feature')
        booleanParam(defaultValue: true, description: '', name: 'ATM_feature')
        booleanParam(defaultValue: true, description: '', name: 'ATR_feature')
        booleanParam(defaultValue: false, description: '', name: 'CodeUpgrade_feature')
        booleanParam(defaultValue: true, description: '', name: 'ComputeMerchantCatergoryCode_feature')
        booleanParam(defaultValue: true, description: '', name: 'CurrencyConversion_feature')
        booleanParam(defaultValue: true, description: '', name: 'ExceptionFile_feature')
        booleanParam(defaultValue: true, description: '', name: 'Field10_with_5_digit_precision_instead_of_6_feature')
        booleanParam(defaultValue: true, description: '', name: 'Indonesia_Local_Standard_Chip_Data_Passthrough_and_Decline_feature')
        booleanParam(defaultValue: true, description: '', name: 'MessageMap_feature')
        booleanParam(defaultValue: false, description: '', name: 'NonEasyCash_feature')
        booleanParam(defaultValue: true, description: '', name: 'PinNoPin_feature')
        booleanParam(defaultValue: true, description: '', name: 'POS_sample_feature')
        booleanParam(defaultValue: true, description: '', name: 'POSDSLRules_feature')
        booleanParam(defaultValue: true, description: '', name: 'Profile_feature')
        booleanParam(defaultValue: true, description: '', name: 'Rejects_feature')
        booleanParam(defaultValue: false, description: '', name: 'Smoke_feature')
        booleanParam(defaultValue: true, description: '', name: 'STIP_feature')
        booleanParam(defaultValue: true, description: '', name: 'Tasks_feature')
        booleanParam(defaultValue: true, description: '', name: 'Umf_feature')

    }
    environment {
        MEDIATOR_1_IP = "${mediator_dc1_ip}"
        MEDIATOR_1_PORT = '59500'
        MEDIATOR_2_IP = "${mediator_dc2_ip}"
        MEDIATOR_2_PORT = '59500'
        UMF_BROKER_1_IP = "${umf_broker_dc1_ip}"
        OVNT_DEBUG = 0
    }
    stages {
        stage('Checkout TESTING Toolkit') {
            steps{
                checkout poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'ssh://git@stash.trusted.visa.com:7999/op/ovn_testing_toolkit_erl.git']]]
            }
        }
        stage('Prepare Cucumber Tests') {
            steps{
                ansiColor('xterm') {
                    sh'''#!/bin/bash -e
                    rm -rf ./deps/
                    make
                    mkdir -p ./report/
                    env'''
                }
            }
        }

    stage('Run Cucumber Tests for ActiveActive_feature') {
    when { expression { return params.ActiveActive_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags a2 -f json -o report/cucumber_ActiveActive_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for ATM_feature') {
    when { expression { return params.ATM_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags atm -f json -o report/cucumber_ATM_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for ATR_feature') {
    when { expression { return params.ATR_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags atr -f json -o report/cucumber_ATR_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for CodeUpgrade_feature') {
    when { expression { return params.CodeUpgrade_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags a2 --tags upgrade -f json -o report/cucumber_CodeUpgrade_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for ComputeMerchantCatergoryCode_feature') {
    when { expression { return params.ComputeMerchantCatergoryCode_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags mcc -f json -o report/cucumber_ComputeMerchantCatergoryCode_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for CurrencyConversion_feature') {
    when { expression { return params.CurrencyConversion_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags currencyconversion -f json -o report/cucumber_currencyconversion.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for ExceptionFile_feature') {
    when { expression { return params.ExceptionFile_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags bug -f json -o report/cucumber_ExceptionFile_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Field10_with_5_digit_precision_instead_of_6_feature') {
    when { expression { return params.Field10_with_5_digit_precision_instead_of_6_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags field10 -f json -o report/cucumber_Field10_with_5_digit_precision_instead_of_6_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Indonesia_Local_Standard_Chip_Data_Passthrough_and_Decline_feature') {
    when { expression { return params.Indonesia_Local_Standard_Chip_Data_Passthrough_and_Decline_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags indochip -f json -o report/cucumber_Indonesia_Local_Standard_Chip_Data_Passthrough_and_Decline_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for MessageMap_feature') {
    when { expression { return params.MessageMap_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags indochip -f json -o report/cucumber_MessageMap_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for NonEasyCash_feature') {
    when { expression { return params.NonEasyCash_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags non_ec --tags need_ea -f json -o report/cucumber_NonEasyCash_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for PinNoPin_feature') {
    when { expression { return params.PinNoPin_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags pinnopin -f json -o report/cucumber_PinNoPin_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for POS_sample_feature') {
    when { expression { return params.POS_sample_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags pos -f json -o report/cucumber_POS_sample_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for POSDSLRules_feature') {
    when { expression { return params.POSDSLRules_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags posdsl -f json -o report/cucumber_POSDSLRules_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Profile_feature') {
    when { expression { return params.Profile_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags profile_attribute -f json -o report/cucumber_Profile_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Rejects_feature') {
    when { expression { return params.Rejects_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags reject -f json -o report/cucumber_Rejects_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Smoke_feature') {
    when { expression { return params.Smoke_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags smoke -f json -o report/cucumber_Smoke_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for STIP_feature') {
    when { expression { return params.STIP_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags stip -f json -o report/cucumber_STIP_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Tasks_feature') {
    when { expression { return params.Tasks_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags switch_task -f json -o report/cucumber_Tasks_feature.json" make kucumberl'
            }
        }
    }

    stage('Run Cucumber Tests for Umf_feature') {
    when { expression { return params.Umf_feature } }
        steps{
            ansiColor('xterm') {
                sh 'OVNT_DEBUG=$OVNT_DEBUG ARGS="--tags umf -f json -o report/cucumber_Umf_feature.json" make kucumberl'
            }
        }
    }

}
    post {
        always {
            sh 'rm -f $(find "report" -size 0 -print)'
            archiveArtifacts 'report'
            cucumber fileIncludePattern: '**/*.json', jsonReportDirectory: 'report', sortingMethod: 'ALPHABETICAL'
        }
        failure {
            echo FAILED
        }
    }
  }
}
//**********************************************************************************************************************
if (flow == 'authLoadTest'){
//**********************************************************************************************************************
// Description: This pipeline is for authorization load test. We don't yet have load test pipeline script.
 }
}
