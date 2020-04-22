def call(String filename) {
  // Prepare datacenter specific vars for later steps.
  // We want to make sure there is a newline separating file concatenation. (see OVN-4405)
  sh """
  for f in inventories/${env.CLUSTER}/${env.DATACENTER}/group_vars/all/${env.DATACENTER}*.yml
  do
    cat \$f | grep -v '\\---'; echo
  done > ${filename}
  """
}