# create the CA
class Vault::Provision::Pki::Intermediate::Generate::Internal < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def gen_file mount_point
    "#{@instance_dir}/#{mount_point}/intermediate/generate/internal.json"
  end

  def provision!
    repo_files_by_mount_type('pki').each do |rf|
      mount_point = rf.split('/')[-4]
      next unless FileTest.file?(gen_file(mount_point))
      next if generated? mount_point
      next unless @pki_allow_destructive
      resp = @vault.post "v1/#{mount_point}/intermediate/generate/internal",
                         File.read(rf)
      sign_intermediate_csr(mount_point, resp[:data][:csr])
    end
  end

  def sign_intermediate_csr mount_point, csr
    return if @intermediate_issuer.empty?
    root_mount = @intermediate_issuer[mount_point.to_sym]
    return if root_mount.nil?

    req = JSON.parse(File.read(gen_file(mount_point)))
    resp = @vault.post "v1/#{root_mount}/root/sign-intermediate",
                       JSON.dump(csr:                  csr,
                                 common_name:          req['common_name'],
                                 ttl:                  req['ttl'],
                                 max_path_length:      0,
                                 exclude_cn_from_sans: true)

    @vault.post "v1/#{mount_point}/intermediate/set-signed",
                JSON.dump(certificate: resp[:data][:certificate])
  end
end
