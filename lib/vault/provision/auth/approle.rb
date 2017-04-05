# placeholder
class Vault::Provision::Auth::Approle < Vault::Provision::Prototype
  def provision!
    repo_files.each do |rf|
      validate_file! rf
      role_name    = File.basename(rf, '.json')
      auth_point   = rf.split('/')[-3]
      role_path    = "auth/#{auth_point}/role/#{role_name}"
      role_id_file = "#{@instance_dir}/#{role_path}/role-id.json"

      puts "  * #{role_path}"
      @vault.post "v1/#{role_path}", File.read(rf)
      next unless FileTest.file? role_id_file
      puts "  * #{role_path}/role-id"
      @vault.post "v1/#{role_path}/role-id", File.read(role_id_file)
    end
  end

  # Vault supports multiple instances of the 'approle' backend mounted
  # concurrently. The map-reducey method repo_files gets the list of
  # approle mounts, calls role_files() once for each of the mounts,
  # then concatenates all those filenames into one big flat array
  def repo_files
    @vault.sys.auths.select { |_,v| v.type == 'approle' }
          .keys
          .inject([]) { |acc, elem| acc + role_files(elem) }
  end

  def role_files auth_point
    Dir.glob("#{@instance_dir}/auth/#{auth_point}/role/*.json").select do |rf|
      FileTest.file?(rf)
    end
  end
end
