curl -X POST https://cloudgateway.trusted.visa.com:8443/cloudgateway/projects \
-H 'Authorization:eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ7XCJ1c2VyTmFtZVwiOlwiYmF0dGVsaVwiLFwibmFtZVwiOlwiQXR0ZWxpLCBCYWxhIEtyaXNobmFcIixcInRwZ3NcIjpbXCJOUFwiXX0iLCJleHAiOjE1ODU3NzM2Nzh9.9g_HLuysDRhXRZBteyx0Sg6rT_xsDrkkIQKZWGTBB2i8_WLA_ceV-JoEIrh1BsgBg3_hvjtgJZ4tzrhhCPERiQ' \
-H 'Content-Type: application/json' \
-d '{
    "application": {
        "applicationNumber": "0018591",
        "applicationName": "Open VisaNet Authorization Clearing Settlement"
    },
    "associatedApplications": [
        {
            "applicationNumber": "0018591",
            "applicationName": "Open VisaNet Authorization Clearing Settlement"
        }
    ],
    "displayName": "'${ProjectName}'",
    "description": "'${Description}'",
    "projectEndDate": "'${ProjectEndDate}'",
    "stack": "Zero Stack_1.0",
    "technologyProductGroup": "NP",
    "key": "'${ProjectKey}'",
    "teamIds": [],
    "stackKey": "Zero Stack_1.0",
    "projectTools": [],
    "createdBy":"batteli"
}' --insecure
