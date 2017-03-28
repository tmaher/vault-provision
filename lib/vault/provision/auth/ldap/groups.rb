# placeholder
class Vault::Provision::Auth::Ldap::Groups < Vault::Provision::Prototype
  def group_files auth_point
    Find.find("#{@instance_dir}/auth/#{auth_point}/groups/").select do |rf|
      FileTest.file?(rf) && rf.end_with?('.json')
    end
  end

  def repo_files
    #auths = @vault.sys.auths
    #auths.keys.select { |ap| auths[ap].type == 'ldap' }
    #     .inject([]) { |acc, elem| acc + group_files(elem) }
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
