#
# This is a documentation to capture vault and Visa CORP LDAP
# integration.
#
# Edit and run this script to configure vault to use Visa CORP ldap
#
vault write auth/ldap/config \
	url="ldaps://sw730visadc09.visa.com:636" \
	userattr="sAMAccountName" \
	userdn="dc=VISA,dc=COM" \
	groupdn="ou=Groups,ou=ISO,dc=VISA,dc=COM" \
        groupattr="memberof" \
        binddn="visa\svcnpovndev" \
        bindpass="<replace with svcnpovndev password>" \
	certificate=@VISACORP.crt \
	insecure_tls=false \
	starttls=false
	