def exec(name, retries, cluster, datacenter) {
    script {
        try {
            ansiblePlaybook playbook: "${name}",
//             extras: '-e jmx_exporter_version="0.9.linux-amd64" -e jmx_exporter_jar="jmx_prometheus_javaagent-0.9.jar"',
               credentialsId: 'ENV.root_key',
               inventory: "inventories/${cluster}/${datacenter}"

        } catch(error) {
            retry(retries) {
                ansiblePlaybook playbook: "${name}",
//                 extras: '-e jmx_exporter_version="0.9.linux-amd64" -e jmx_exporter_jar="jmx_prometheus_javaagent-0.9.jar"',
                   credentialsId: 'ENV.root_key',
                   inventory: "inventories/${cluster}/${datacenter}",
                   limit: "@${name}".replace('.yml','.retry')
            }
        }
    }
}
return this
