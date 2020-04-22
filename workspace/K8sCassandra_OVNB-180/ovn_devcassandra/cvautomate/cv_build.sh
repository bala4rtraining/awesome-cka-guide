curl -X POST https://cloudview.trusted.visa.com/@apps-container-quick-launch/@buildService/pipelines/"$PipelineId"/builds \
-H 'Authorization:eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ7XCJ1c2VyTmFtZVwiOlwiYmF0dGVsaVwiLFwibmFtZVwiOlwiQXR0ZWxpLCBCYWxhIEtyaXNobmFcIixcInRwZ3NcIjpbXCJOUFwiXX0iLCJleHAiOjE1ODU3NzM2Nzh9.9g_HLuysDRhXRZBteyx0Sg6rT_xsDrkkIQKZWGTBB2i8_WLA_ceV-JoEIrh1BsgBg3_hvjtgJZ4tzrhhCPERiQ' \
-H 'Content-Type: application/json' \
-d '{"environmentVariables":[],"dockerfile":null}' --insecure
