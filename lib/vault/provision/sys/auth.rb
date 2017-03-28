# helps to enable authentication
class Vault::Provision::Sys::Auth < Vault::Provision::Prototype
  def provision!
    auths = @vault.sys.auths

    change = []
    repo_files.each do |rf|
      path = rf[(repo_path.length + 1)..-6].to_sym
      r_conf = JSON.parse(File.read(rf))

      next if auths[path]
      @vault.sys.enable_auth(path.to_s,
                             r_conf['type'], r_conf['description'])
      change << @vault.sys.auths[path]
    end

    change
  end
end
