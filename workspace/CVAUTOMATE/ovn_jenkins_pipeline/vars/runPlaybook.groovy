// This shared library is runPlaybook without retry.

import static com.visa.ovn.Utilities.*

def call(name, cluster, datacenter, def forks=5, def extras_vars="-e optional=true") {
  return {
      ansiblePlaybook playbook: "${name}",
      credentialsId: 'ENV.root_key',
      forks: forks.toInteger(),
      colorized: true,
      extras: "$extras_vars",
      inventory: "inventories/${cluster}/${datacenter}"
  }
}
