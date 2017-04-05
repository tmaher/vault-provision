# let there be authentication backends!
class Vault::Provision::Auth; end

require 'vault/provision/auth/ldap'
require 'vault/provision/auth/approle'
