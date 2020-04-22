#
# allow list and read operation to view the list of ssh_ca roles and view details
#
path "sys/mounts" {
  capabilities = ["list", "read"]
}

path "sys/mounts/*" {
  capabilities = ["list", "read"]
}

#
# allow list and read operation to view the list of ssh_ca roles and view details
#
path "ssh/*" {
  capabilities = ["list", "read"]
}
