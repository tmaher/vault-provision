# config LDAP authn
class Vault::Provision::Auth::Ldap::Config < Vault::Provision::Prototype
  def ap_file auth_point
    "#{@instance_dir}/auth/#{auth_point}/config.json"
  end

  def repo_files
    return @repo_files if @repo_files
    auths = @vault.sys.auths

    aps = auths.keys.select do |auth_point|
      next unless auths[auth_point].type == 'ldap'
      next unless FileTest.file? ap_file(auth_point)

      repo_config  = JSON.parse(File.read(ap_file(auth_point)))
      vault_config = begin
                       @vault.get("auth/#{auth_point}config")['data']
                     rescue Vault::HTTPClientError => e
                       raise e unless e.code == 404
                       {}
                     end

      # for each key in the repo JSON file's hash, compare to current
      # vault state. If they're identical, go on to the next mount point.
      !repo_config.keys.inject(true) { |acc,elem| acc && vault_config[elem] == repo_config[elem]}
    end
    map_out = aps.map { |auth_point| ap_file(auth_point) }
    @repo_files = map_out
  end

  def provision!
    repo_files.each do |rf|
      auth_point = rf.split('/')[-2]
      @vault.post "v1/auth/#{auth_point}/config", File.read(rf)
    end
  end
end
