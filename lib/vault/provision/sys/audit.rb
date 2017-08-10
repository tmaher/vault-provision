# helps to enable auditing
class Vault::Provision::Sys::Audit < Vault::Provision::Prototype
  def provision!
    audits = @vault.sys.audits

    change = []
    repo_files.each do |rf|
      validate_file! rf
      path = rf[(repo_path.length + 1)..-6].to_sym
      r_conf = JSON.parse(File.read(rf))
      next unless backend_changed? audits[path], r_conf

      @vault.sys.enable_audit(path.to_s,
                              r_conf['type'],
                              r_conf['description'],
                              r_conf['options'])
      change << @vault.sys.audits[path]
    end
    change
  end

  def backend_changed?(vault_conf, file_conf)
    return true unless vault_conf
    file_conf.each { |k, v| return true if v != vault_conf.to_h[k] }
    false
  end
end
