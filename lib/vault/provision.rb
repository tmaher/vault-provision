require 'vault'
require 'active_support/inflector'

class Vault::Provision; end
require 'vault/provision/prototype'

require 'vault/provision/auth'
require 'vault/provision/sys'
require 'vault/provision/pki'
require 'vault/provision/secret'

# controller for the children
class Vault::Provision
  SYSTEM_POLICIES = ['response-wrapping', 'root'].freeze

  attr_accessor :vault, :instance_dir, :intermediate_issuer

  def initialize instance_dir,
                 address: ENV['VAULT_ADDR'],
                 token: ENV['VAULT_TOKEN'],
                 intermediate_issuer: {},
                 pki_force: false

    @instance_dir = instance_dir
    @vault = Vault::Client.new address: address, token: token
    @intermediate_issuer = intermediate_issuer
    @pki_force = pki_force
    @handlers = [
      Sys::Auth,
      Auth::Ldap::Config,
      Sys::Mounts,
      Pki::Root::Generate::Internal,
      Pki::Intermediate::Generate::Internal,
      Pki::Config::Urls,
      Pki::Roles,
      #Secret,
      Sys::Policy,
      #Auth::Ldap::Groups,
    ]
  end

  def provision!
    @handlers.each do |handler|
      puts "* Calling handler #{handler}"
      handler.new(self).provision!
    end
  end

  def pki_force?
    @pki_force
  end
end
