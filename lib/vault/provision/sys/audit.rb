# helps to enable auditing
class Vault::Provision::Sys::Audit < Vault::Provision::Prototype
  def provision!
    change = []
    repo_files.each do |rf|
      audits = @vault.sys.audits
      validate_file! rf
      path = rf[(repo_path.length + 1)..-6]
      r_conf = JSON.parse(File.read(rf))
      next unless backend_changed? audits[path.to_sym], r_conf

      # API only lets you delete & re-create audit backends
      # No upcerts allowed :(
      if backend_exists?(path)
        puts "  * #{path} changed, disabling for update"
        @vault.sys.disable_audit(path)
      end

      puts "  * #{path} enabled"
      @vault.sys.enable_audit(path,
                              r_conf['type'],
                              r_conf['description'],
                              r_conf['options'])
      change << @vault.sys.audits[path.to_sym]
    end
    change
  end

  def backend_changed?(vault_conf, file_conf)
    return true unless vault_conf
    file_conf.each { |k, v| return true if v != vault_conf.to_h[k] }
    false
  end

  def backend_exists?(path)
    !@vault.sys.audits[path.to_sym].nil?
  end
end
