#
# allow list and read operation to view the list of ssh_ca roles and view details
#
path "ssh/*" {
  capabilities = ["list", "read"]
}

path "ssh/sign/appsupportrole" {
  capabilities = ["update"]
  allowed_parameters = {
    "public_key" = []
  }
}
