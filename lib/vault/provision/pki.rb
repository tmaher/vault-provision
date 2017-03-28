# PKI/CA backend provisioning
module Vault::Provision::Pki
  # placeholder
  class Root; end
  # placeholder
  class Intermediate; end

  def generated? path
    @vault.get "#{path}/ca/pem"
    true
  rescue Vault::HTTPClientError
    false
  end

  def ca_type path
    path.match(/pki-intermediate/) && true
  end
end

require 'vault/provision/pki/root'
require 'vault/provision/pki/intermediate'
require 'vault/provision/pki/config'
require 'vault/provision/pki/roles'
require 'vault/provision/pki/sign_intermediates_with_root'
