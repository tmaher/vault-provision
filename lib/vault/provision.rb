require 'vault'
require 'active_support/inflector'

# controller for the children
class Vault::Provision
  attr_accessor :vault, :instance_dir

  def initialize instance_dir,
                 address: ENV['VAULT_ADDR'],
                 token: ENV['VAULT_TOKEN'],
                 pki_force: false

    @instance_dir = instance_dir
    @vault = Vault::Client.new address: address, token: token
    @pki_force = pki_force
    @handlers = [
      Sys::Auth,
      Auth::Ldap::Config,
      Sys::Mounts,
      #Sys::Policy,
      #Auth::Ldap::Groups,
      #Pki::Config,
      #Pki::Root::Generate,
      #Pki::Roles,
      #Secret,
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

# prototype for the individual hierarchy paths
class Vault::Provision::Prototype
  def initialize boss
    @vault = boss.vault
    @instance_dir = boss.instance_dir
  end

  def repo_prefix
    ActiveSupport::Inflector.underscore(self.class.to_s)
                            .split('/')[2..-1].join('/')
  end

  def repo_path
    "#{@instance_dir}/#{repo_prefix}"
  end

  def repo_files
    Find.find(repo_path).select { |rf| rf.end_with?('.json') }
  end

  def provision!
    puts "#{self.class} says: Go climb a tree!"
  end
end

require 'vault/provision/auth'
require 'vault/provision/sys'
require 'vault/provision/pki'
require 'vault/provision/secret'
