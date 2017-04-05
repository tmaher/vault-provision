# placeholder
class Vault::Provision::Auth::Approle < Vault::Provision::Prototype
  def provision!
    repo_files.each do |rf|
      role = File.basename(rf, '.json')
      auth_point = rf.split('/')[-3]
      @vault.post "v1/auth/#{auth_point}/role/#{role}", File.read(rf)
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
