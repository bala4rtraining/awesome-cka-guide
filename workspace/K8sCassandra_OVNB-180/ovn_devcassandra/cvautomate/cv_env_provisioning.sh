curl -X POST 'https://cloudview.trusted.visa.com/@api/paas/environments' \
-H 'Authorization:eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ7XCJ1c2VyTmFtZVwiOlwiYmF0dGVsaVwiLFwibmFtZVwiOlwiQXR0ZWxpLCBCYWxhIEtyaXNobmFcIixcInRwZ3NcIjpbXCJOUFwiXX0iLCJleHAiOjE1ODU3NzM2Nzh9.9g_HLuysDRhXRZBteyx0Sg6rT_xsDrkkIQKZWGTBB2i8_WLA_ceV-JoEIrh1BsgBg3_hvjtgJZ4tzrhhCPERiQ' \
-H 'Content-Type: application/json' \
-d '{
    "name": "'"$EnvName"'",
    "account": "NP",
    "project": "'"$ProjectKey"'",
    "providerType": "CONTAINER",
    "callbackUrl": "",
    "deploymentModelId": "5c9bde6de4b09069d9abb55a",
    "deploymentModelVersion": 1,
    "resources": [
        {
            "serverSpecification": {
                "serverType": "Application",
                "soi": "RHEL7.4.1",
                "instanceType": "2x4",
                "isBackupRequired": false,
                "includeList": null,
                "excludeList": ""
            },
            "networkSpecification": {
                "zone": "Business",
                "dataCenter": "OCE",
                "network": "CONTAINER-NON-PROD-GEN",
                "domain": "visa.com",
                "adDomain": ""
            },
            "key": "r1",
            "storage": [],
            "providerType": "CONTAINER",
            "quantity": 1,
            "dependsOn": 0,
            "stacks": [
                {
                    "stackUUID": "57eaf11be4b0e3539febc883",
                    "type": "All",
                    "softwarePackages": [
                        {
                            "packageUUID": "57eaf0d1e4b0e3539febc881",
                            "attributes": {
                                "business_justification": ""
                            }
                        }
                    ]
                }
            ],
            "id": 1,
            "ui": {
                "resourceModel": {
                    "id": 1,
                    "serverType": "Application",
                    "zone": "Business",
                    "stackModels": [
                        {
                            "stackId": "'"$STACK_ID"'",
                            "stackKey": "Zero Stack_1.0",
                            "packageIds": [
                                "57eaf0d1e4b0e3539febc881"
                            ],
                            "packageKeys": [
                                "Zero Package"
                            ]
                        }
                    ],
                    "constraints": [],
                    "dependsOn": 0,
                    "minQuantity": 1,
                    "maxQuantity": 30,
                    "resourceKey": "r1",
                    "postProvisioningTasks": [],
                    "type": "SIMPLE",
                    "resourceModels": [],
                    "containerSupported": null,
                    "deleted": false,
                    "stacks": [
                        {
                            "name": "Zero Stack",
                            "version": "1.0",
                            "type": "All",
                            "provider": "Chef",
                            "status": "PUBLISHED",
                            "key": "Zero Stack_1.0",
                            "id": "'"$STACK_ID"'",
                            "packages": [
                                {
                                    "id": "57eaf0d1e4b0e3539febc881",
                                    "key": "zero_package_1.0",
                                    "name": "Zero Package",
                                    "version": "1.0",
                                    "productKey": null,
                                    "externalProvider": "Chef",
                                    "externalPackageKey": "visa_analytics",
                                    "externalPackageVersion": "_latest",
                                    "globalServiceGroups": [
                                        "icmp-proto"
                                    ],
                                    "certificateSupported": false,
                                    "certificateRequired": false,
                                    "certificateType": null,
                                    "productType": null,
                                    "databaseType": null,
                                    "attributeSchema": {
                                        "type": "object",
                                        "id": "urn:jsonschema:com:visa:cloud:gateway:model:ZeroPackageAttributes",
                                        "description": "Attributes to define a Zero Package installation",
                                        "properties": {
                                            "business_justification": {
                                                "title": "List any software you are planning to install after the server is provisioned",
                                                "type": "string",
                                                "default": "",
                                                "pattern": "",
                                                "description": "List any software you are planning to",
                                                "validationMessage": "Please provide valid package name(s)",
                                                "minLength": 3
                                            }
                                        },
                                        "required": [
                                            "business_justification"
                                        ]
                                    },
                                    "preRequisites": [],
                                    "constraints": [],
                                    "isActive": true,
                                    "portJsonPathExpressions": null,
                                    "passwordJsonPathExpressions": null,
                                    "customValidationModels": null,
                                    "techGovProductNamesRequired": false,
                                    "createdBy": null,
                                    "lastUpdatedBy": "kkadambi",
                                    "createdDate": null,
                                    "lastUpdatedDate": 1562083684862,
                                    "productOwner": null,
                                    "technicalDelegate": null,
                                    "classification": "PRIMARY",
                                    "approvalGroup": null,
                                    "rebootRequired": false,
                                    "technologyName": null,
                                    "technologyId": null,
                                    "ilmTicketId": null,
                                    "validatorBeanName": null,
                                    "technologyType": "CUSTOM",
                                    "technologySME": null,
                                    "lastUpdatedOn": null,
                                    "updatedBy": null,
                                    "new": false,
                                    "attributes": {
                                        "business_justification": ""
                                    }
                                }
                            ],
                            "packageNames": [
                                "Zero Package"
                            ]
                        }
                    ]
                },
                "certificateSupported": false,
                "certificateRequired": false,
                "certificateProvided": false,
                "stacks": [],
                "configured": true,
                "techGovProductNamesRequired": false
            },
            "postProvisioningTasks": [],
            "applicationSpecifications": [],
            "offerings": [
                {
                    "id": "a47f226ddb564b843f0af5441d9619f3",
                    "name": "AO_perfmgmt",
                    "className": "Service Offering",
                    "correlationId": "ASGAA5V0GO441AN9XUV3P64H3YCEYU",
                    "offeringType": "Application",
                    "instanceID": "",
                    "shortDescription": "",
                    "sys_id": "a47f226ddb564b843f0af5441d9619f3"
                },
                {
                    "id": "a87f226ddb564b843f0af5441d9619c8",
                    "name": "AO_OVN",
                    "className": "Service Offering",
                    "correlationId": "ASGAA5V0GO441AN7QEA5Y5ZC9G6U70",
                    "offeringType": "Application",
                    "instanceID": "",
                    "shortDescription": "",
                    "sys_id": "a87f226ddb564b843f0af5441d9619c8"
                },
                {
                    "id": "3e6fee2ddb564b843f0af5441d961931",
                    "name": "AO_engtools_support",
                    "className": "Service Offering",
                    "correlationId": "AS005056A47552YxqIUALiM8FwC5t6",
                    "instanceID": "",
                    "shortDescription": "",
                    "sys_id": "3e6fee2ddb564b843f0af5441d961931"
                },
                {
                    "id": "cb6fee2ddb564b843f0af5441d961946",
                    "name": "AO_WAS",
                    "className": "Service Offering",
                    "correlationId": "AS005056A453C59ZiaUAiIBJFwtvFu",
                    "offeringType": "Application",
                    "instanceID": "",
                    "shortDescription": "",
                    "sys_id": "cb6fee2ddb564b843f0af5441d961946"
                },
                {
                    "id": "c57f626ddb564b843f0af5441d961966",
                    "name": "AO_CASSANDRA",
                    "className": "Service Offering",
                    "correlationId": "ASGAA5V0GO441ANTDBXW9563IIIKF4",
                    "offeringType": "Application",
                    "instanceID": "",
                    "shortDescription": "",
                    "sys_id": "c57f626ddb564b843f0af5441d961966"
                }
            ],
            "certificateSpecification": null,
            "additionalSpecification": [],
            "exceptionCode": "",
            "businessJustification": "",
            "additionalIPCount": 0,
            "additionalCertSpecifications": [],
            "containerSpecification": {
                "projectId": "'"$ProjectKey"'",
                "deploymentId": "5e5cc0305eb9a65c358f5dc9",
                "buildId": "'"$buildId"'",
                "serviceDNS": "",
                "cpu": 0.25,
                "memory": 512,
                "cpuLimit": 1,
                "memoryLimit": 2048,
                "certificateNeeded": false,
                "certificatePassword": "",
                "certificatePath": "",
                "portMappings": [
                    {
                        "ports": [
                            {
                                "external": true,
                                "servicePort": 8080,
                                "targetPort": 8080,
                                "termination": "Edge"
                            }
                        ],
                        "serviceUrl": "'"$serviceUrl"'",
                        "customLabels": {}
                    }
                ],
                "deploymentType": "REPLICA_DEPLOYMENT",
                "kubernetesSpecification": null,
                "scalingType": "MANUAL",
                "customLabels": {},
                "readinessProbe": null,
                "livenessProbe": null,
                "terminationGracePeriodSeconds": 30
            },
            "techGovRegisteredProducts": [],
            "bootOption": "",
            "osDiskType": "",
            "hardware": "",
            "physicalServerSpecifications": [
                {
                    "hostname": "",
                    "serial": "",
                    "ip": "",
                    "netMask": "",
                    "gateway": ""
                }
            ],
            "physicalStorageConfigured": false,
            "physicalStorage": [],
            "propertiesValid": true
        }
    ],
    "environmentType": "Development",
    "purpose": "None",
    "leaseEndDate": "2020-06-02T08:17:42.346Z",
    "leaseStartDate": "2020-03-02T08:19:39.961Z",
    "applicationSpecification": {
        "application": "0018591",
        "applicationName": "Open VisaNet Authorization Clearing Settlement",
        "environmentName": "OVNDEV"
    },
    "tags": []
}' --insecure
