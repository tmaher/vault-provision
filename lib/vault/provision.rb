require 'vault'
require 'active_support/inflector'

class Vault::Provision; end
require 'vault/provision/prototype'

require 'vault/provision/auth'
require 'vault/provision/sys'
require 'vault/provision/pki'
require 'vault/provision/generic'

# controller for the children
class Vault::Provision
  SYSTEM_POLICIES = ['response-wrapping', 'root'].freeze

  attr_accessor :vault, :instance_dir,
                :intermediate_issuer, :pki_allow_destructive

  def initialize instance_dir,
                 address: ENV['VAULT_ADDR'],
                 token: ENV['VAULT_TOKEN'],
                 intermediate_issuer: {},
                 pki_allow_destructive: false

    @instance_dir = instance_dir
    @vault = Vault::Client.new address: address, token: token
    @intermediate_issuer = intermediate_issuer
    @pki_allow_destructive = pki_allow_destructive
    @handlers = [
      Sys::Auth,
      Auth::Ldap::Config,
      Sys::Mounts,
      Pki::Root::Generate::Internal,
      Pki::Intermediate::Generate::Internal,
      Pki::Config::Urls,
      Pki::Roles,
      Generic,
      Sys::Policy,
      Auth::Ldap::Groups,
      Auth::Approle
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
