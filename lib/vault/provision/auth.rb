# let there be authentication backends!
class Vault::Provision::Auth
  class Vault::Provision::Auth::Ldap; end
end

# config LDAP authn
class Vault::Provision::Auth::Ldap::Config < Vault::Provision::Prototype
  def provision!
    # Get a list of all active LDAP auth mounts. For each mount,
    # if we have a config, apply it.
    paths = @vault.sys.auths.select { |_,a| a.type == :ldap } .keys
    paths.each do |path|
      rf = "#{@instance_dir}/auth/#{path}config.json"
      rc = JSON.dump(File.read(rf))
      vc = @vault.get("auth/#{path}config")['data']

      # for each key in the repo JSON file's hash, compare to current
      # vault state. If they're identical, go on to the next mount point.
      next if rc.keys.inject(true) { |acc, elem| acc && (vc[elem] == rc[elem]) }

      @vault.post "auth/#{path}config", rc
    end
  end
end

class Vault::Provision::Auth::Ldap::Groups < Vault::Provision::Prototype
end
