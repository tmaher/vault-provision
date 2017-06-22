# templates for certs
class Vault::Provision::Pki::Roles < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def repo_files
    repo_files_by_mount_type('pki').select { |rf| rf.split('/')[-2] == 'roles' }
  end

  def provision!
    repo_files.each do |rf|
      mount_point = rf.split('/')[-3]
      role_name = File.basename(rf, '.json')
      puts "  * #{role_name}"
      @vault.post "v1/#{mount_point}/roles/#{role_name}", File.read(rf)
    end
  end
end
