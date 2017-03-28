# templates for certs
class Vault::Provision::Pki::Roles < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def repo_files
    mounts = @vault.sys.mounts
    pki_mounts = mounts.keys.select { |mp| mounts[mp].type == 'pki' }
    roles = []
    pki_mounts.each do |mp|
      Find.find("#{@instance_dir}/#{mp}/roles/").each do |rf|
        next unless rf.end_with? '.json'
        roles << rf
      end
    end
    roles
  end

  def provision!
    repo_files.each do |rf|
      mount_point = rf.split('/')[-3]
      role_name = File.basename(rf, '.json')
      @vault.post "v1/#{mount_point}/roles/#{role_name}", File.read(rf)
    end
  end
end
