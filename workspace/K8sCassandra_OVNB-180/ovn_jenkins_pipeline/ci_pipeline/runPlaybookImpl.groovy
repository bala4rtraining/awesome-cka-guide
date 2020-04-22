// This shared library is runPlaybook without retry.


def exec(name, cluster, datacenter, forks, extras_vars) {

  try {
      ansiblePlaybook playbook: "${name}",
      credentialsId: 'ENV.root_key',
      forks: forks.toInteger(),
      colorized: true,
      extras: "$extras_vars",
      inventory: "inventories/${cluster}/${datacenter}"

  } catch(error) {
      println("Error ${error} found in running ansible playbook - ${name}");
  }

}
return this
