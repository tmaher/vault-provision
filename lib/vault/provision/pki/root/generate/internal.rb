# create the CA
class Vault::Provision::Pki::Root::Generate::Internal < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def gen_file mount_point
    "#{@instance_dir}/#{mount_point}/root/generate/internal.json"
  end

  def provision!
    repo_files_by_mount_type('pki').each do |rf|
      mount_point = rf.split('/')[-4]
      next unless FileTest.file?(gen_file(mount_point))
      next if generated? mount_point
      next unless @pki_allow_destructive
      @vault.post "v1/#{mount_point}/root/generate/internal", File.read(rf)
    end
  end
end
