# PKI/CA backend provisioning
module Vault::Provision::Pki
  # placeholder
  class Root; end
  # placeholder
  class Intermediate; end

  def generated? path
    result = @vault.get "v1/#{path}/ca/pem"
    return true if result =~ /BEGIN CERTIFICATE/
  rescue Vault::HTTPClientError
    return false
  end

  def ca_type path
    path.match(/pki-intermediate/) && true
  end
end

require 'vault/provision/pki/root'
require 'vault/provision/pki/intermediate'
require 'vault/provision/pki/config'
require 'vault/provision/pki/roles'
