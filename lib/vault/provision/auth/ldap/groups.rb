# placeholder
class Vault::Provision::Auth::Ldap::Groups < Vault::Provision::Prototype
  def group_files auth_point
    groups_path = "#{@instance_dir}/auth/#{auth_point}/groups/"
    return [] unless Dir.exist? groups_path
    Find.find(groups_path).select do |rf|
      FileTest.file?(rf) && rf.end_with?('.json')
    end
  end

  # Vault supports multiple instances of the 'ldap' backend mounted
  # concurrently. The map-reducey method repo_files gets the list of
  # ldap mounts, calls group_files() once for each of the mounts,
  # then concatenates all those filenames into one big flat array
  def repo_files
    @vault.sys.auths.select { |_,v| v.type == 'ldap' }
          .keys
          .inject([]) { |acc, elem| acc + group_files(elem) }
  end

  def provision!
    repo_files.each do |rf|
      group = File.basename(rf, '.json')
      auth_point = rf.split('/')[-3]
      @vault.post "v1/auth/#{auth_point}/groups/#{group}", File.read(rf)
    end
  end
end
