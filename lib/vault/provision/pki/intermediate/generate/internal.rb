# create the CA
class Vault::Provision::Pki::Intermediate::Generate::Internal < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def gen_file mount_point
    "#{@instance_dir}/#{mount_point}/intermediate/generate/internal.json"
  end

  def repo_files
    mounts = @vault.sys.mounts
    generators = mounts.keys.select do |mp|
      mounts[mp].type == 'pki' && FileTest.file?(gen_file(mp))
    end
    generators.map { |mp| gen_file(mp) }
  end

  def provision!
    repo_files.each do |rf|
      mount_point = rf.split('/')[-4]
      next if generated? mount_point
      resp = @vault.post "v1/#{mount_point}/intermediate/generate/internal",
                         File.read(rf)
      sign_intermediate_csr(mount_point, resp[:data][:csr])
    end
  end

  def sign_intermediate_csr mount_point, csr
    return if @intermediate_issuer.empty?
    root = @intermediate_issuer[mount_point.to_sym]
    return if root.nil?

    req = JSON.parse(File.read(gen_file(mount_point)))
    resp = @vault.post "v1/#{root}/root/sign-intermediate",
                       JSON.dump(csr:                  csr,
                                 common_name:          req['common_name'],
                                 ttl:                  req['ttl'],
                                 max_path_length:      0,
                                 exclude_cn_from_sans: true)

    @vault.post "v1/#{mount_point}/intermediate/set-signed",
                JSON.dump(certificate: resp[:data][:certificate])
  end
end
