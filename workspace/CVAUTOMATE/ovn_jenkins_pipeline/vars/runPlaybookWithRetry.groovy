import static com.visa.ovn.Utilities.*

def call(name, retries, cluster, datacenter) {
    script {
        try {
            ansiblePlaybook playbook: "${name}",
               credentialsId: 'ENV.root_key',
               inventory: "inventories/${cluster}/${datacenter}"

        } catch(error) {
            retry(retries) {
                ansiblePlaybook playbook: "${name}",
                   credentialsId: 'ENV.root_key',
                   inventory: "inventories/${cluster}/${datacenter}",
                   limit: "@${name}".replace('.yml','.retry')
            }
        }
    }
}
return this

