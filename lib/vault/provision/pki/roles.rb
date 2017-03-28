# templates for certs
class Vault::Provision::Pki::Roles < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def provision!
    paths = @vault.sys.mounts.select { |_,a| a.type == 'pki' } .keys

    changes = []
    paths.each do |path|
      repo_path = "#{@instance_dir}/#{path}/roles"
      roles = begin
                @vault.list("#{path}/roles")['data']['keys']
              rescue Vault::HTTPClientError
                []
              end

      Find.find(repo_path).each do |rf|
        next unless rf.end_with? '.json'
        role_name = File.basename(rf, '.json')
        puts "** pki #{path}, role #{role_name}"

        if roles.include? role_name
          r_role = JSON.dump(File.read(rf))
          v_role = @vault.get("#{path}roles/#{role_name}")['data']
          next if v_role.keys.inject(true) { |acc,elem| acc && v_role[elem] == r_role[elem] }
        end

        puts "** CREATING pki #{path}, role #{role_name}"
        @vault.post("#{path}roles/#{role_name}", r_role)
        changes << @vault.get("#{path}roles/#{role_name}")['data']
      end
    end
    changes
  end
end
