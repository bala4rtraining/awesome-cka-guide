curl -X POST https://cloudview.trusted.visa.com/@apps-container-quick-launch/@cg/projects \
-H 'Authorization:eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ7XCJ1c2VyTmFtZVwiOlwiYmF0dGVsaVwiLFwibmFtZVwiOlwiQXR0ZWxpLCBCYWxhIEtyaXNobmFcIixcInRwZ3NcIjpbXCJOUFwiXX0iLCJleHAiOjE1ODU3NzM2Nzh9.9g_HLuysDRhXRZBteyx0Sg6rT_xsDrkkIQKZWGTBB2i8_WLA_ceV-JoEIrh1BsgBg3_hvjtgJZ4tzrhhCPERiQ' \
-H 'Content-Type: application/json' \
-d '{
    "key":"'"$ProjectKey"'",
    "technologyProductGroup": "NP",
    "description": "for cv api automation",
    "projectState": {
        "id":"'"$PROJECT_ID"'",
        "name": "Planning"
    },
    "projectEndDate": 1613811978452,
    "projectTools": [
        {
            "url": "https://sonar.trusted.visa.com",
            "displayName": "Sonar Url",
            "type": "SONAR"
        },
        {
            "url": "ssh://git@stash.trusted.visa.com:7999/op/ovn_devcassandra.git",
            "type": "STASH",
            "displayName": "GIT/Stash Project",
            "properties": {
                "repoSlug": "ovn_devcassandra",
                "toolAdmin": "batteli",
                "projectKey":"'"$ProjectKey"'"
            }
        }
    ],
    "stackKey": "Zero Stack_1.0",
    "id":"'"$STACK_ID"'",
    "createdBy": "batteli",
    "application": {
        "applicationNumber": "0018591",
        "applicationName": "Open VisaNet Authorization Clearing Settlement"
    },
    "plugins": {
        "projectBlackDuckName": {
            "pluginId": null,
            "values": "NP_Open-VisaNet-Authorization-Clearing-Settlement_AskNowId_0018591"
        }
    },
    "displayName":"'"$ProjectName"'",
    "associatedApplications": [
        {
            "applicationNumber": "0018591",
            "applicationName": "Open VisaNet Authorization Clearing Settlement"
        }
    ]
}' --insecure
