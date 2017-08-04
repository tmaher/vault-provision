require 'find'

# systems backend provisioning
class Vault::Provision::Sys; end
require 'vault/provision/sys/audit'
require 'vault/provision/sys/auth'
require 'vault/provision/sys/policy'

# secret mounts
class Vault::Provision::Sys::Mounts < Vault::Provision::Prototype
  SYSTEM_MOUNTS = [
    'token',
    'cubbyhole',
    'sys',
    'secret'
  ].freeze

  def provision!
    mounts = @vault.sys.mounts

    repo_path = "#{@instance_dir}/sys/mounts"
    change = []
    Find.find(repo_path).each do |rf|
      next unless rf.end_with?('.json')
      next if rf.end_with?('/tune.json')

      rf_base = File.basename rf, '.json'
      next if SYSTEM_MOUNTS.include? rf_base

      path = rf[(repo_path.length + 1)..-6].to_sym
      r_conf = JSON.parse(File.read(rf))
      rcc = r_conf['config'] || {}

      unless mounts[path]
        @vault.sys.mount(path.to_s, r_conf['type'], r_conf['description'])
        @vault.sys.mount_tune(path.to_s, rcc)
        change << @vault.sys.mounts[path]
        next
      end

      vmc = mounts[path].config || {}
      next if rcc.keys.inject(true) { |acc, elem| acc && (vmc[elem.to_sym] == rcc[elem]) }

      @vault.sys.mount_tune(path.to_s, rcc)
      change << @vault.sys.mounts[path]
    end
    change
  end
end
