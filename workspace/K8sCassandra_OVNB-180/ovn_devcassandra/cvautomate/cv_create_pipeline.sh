curl -X POST https://cloudview.trusted.visa.com/@apps-container-quick-launch/@buildService/projects/"$ProjectKey"/pipelines \
-H 'Authorization:eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ7XCJ1c2VyTmFtZVwiOlwiYmF0dGVsaVwiLFwibmFtZVwiOlwiQXR0ZWxpLCBCYWxhIEtyaXNobmFcIixcInRwZ3NcIjpbXCJOUFwiXX0iLCJleHAiOjE1ODU3NzM2Nzh9.9g_HLuysDRhXRZBteyx0Sg6rT_xsDrkkIQKZWGTBB2i8_WLA_ceV-JoEIrh1BsgBg3_hvjtgJZ4tzrhhCPERiQ' \
-H 'Content-Type: application/json' \
-d '{
    "name": "testkey-Development-1584295104397",
    "tpgKey": "NP",
    "buildSpecification": {
        "buildTool": "zero-stack",
        "buildToolVersion": "1.0",
        "containerImage": true,
        "gitBranchName": "feature/OVNB-180_Cassandra_containerize_pipeline",
        "gitRepoUrl": "ssh://git@stash.trusted.visa.com:7999/op/ovn_devcassandra.git",
        "gitBranchId": "refs/heads/feature/OVNB-180_Cassandra_containerize_pipeline",
        "buildSteps": [
            {
                "stepId": "5ad09e60c24717717e1043a4",
                "name": "Git Clone",
                "description": null,
                "key": "git-clone",
                "attributeSchema": {
                    "type": "object",
                    "properties": {
                        "url": {
                            "title": "Repository URL",
                            "type": "string"
                        },
                        "branch": {
                            "title": "Branch",
                            "type": "string"
                        }
                    }
                },
                "configurable": false,
                "attributes": {}
            },
            {
                "stepId": "5ad304f6c24322941747f156",
                "name": "Docker Build",
                "description": null,
                "key": "docker-build",
                "attributeSchema": null,
                "configurable": false,
                "attributes": {}
            },
            {
                "stepId": "5ad311f4c24322941748725e",
                "name": "Docker Publish",
                "description": null,
                "key": "docker-publish",
                "attributeSchema": null,
                "configurable": false,
                "attributes": {}
            }
        ],
        "imageBuildSpecification": {
            "dockerfileRepoPath": "Dockerfile",
            "dockerFile": "FROM nonprod.registry.trusted.visa.com/oi-0024789/jdk18rhel7:jdk18rhel7-development_1\n\nRUN curl -o cassandra.tar https://artifactory.trusted.visa.com/ovn-extra-el7/apache-cassandra-3.11.4.tar --insecure\nRUN tar --warning=no-unknown-keyword -zxf cassandra.tar\nRUN mv apache-cassandra-3.11.4 cassandra\nCOPY ./cass_conf.sh cassandra/\nCOPY ./start.sh cassandra/\nCOPY ./schema.txt cassandra/\n\nWORKDIR cassandra\nRUN chmod +x start.sh\nRUN chmod +x cass_conf.sh\nRUN chmod +x schema.txt\n\nRUN mkdir logs\nRUN touch logs/gc.log\nRUN chmod -R 777 .\n\nENTRYPOINT [ \"./start.sh\" ]\nEXPOSE 9042\n",
            "autoUpdateDockerfile": false
        },
        "jenkinsPipeline": ""
    },
    "deploySpecification": {
        "environmentVariables": [],
        "configurationRoleId": null,
        "artifactDeployConfiguration": {
            "serverNames": [],
            "deployType": "PARALLEL"
        },
        "configurationRoleName": null,
        "configurationRoleDetails": []
    },
    "environmentType": "Development",
    "projectKey": "'"$ProjectKey"'",
    "ciPipeline": false,
    "configurablePipeline": false,
    "plugins": {},
    "promotionApprovals": [],
    "deployApprovals": [],
    "autoBuildEnabled": false,
    "autoDeployEnabled": false,
    "validationPipelineConstruct": [],
    "isCloneable": true,
    "autoPromoteOnBuild": []
}' --insecure
