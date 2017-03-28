# config crl & distribution points for CAs
class Vault::Provision::Pki::Config::Urls < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def urls_file mount_point
    "#{@instance_dir}/#{mount_point}/config/urls.json"
  end

  def repo_files
    mounts = @vault.sys.mounts
    pki_mounts = mounts.keys.select do |mp|
      mounts[mp].type == 'pki' && FileTest.file?(urls_file(mp))
    end
    pki_mounts.map { |mp| urls_file(mp) }
  end

  def provision!
    repo_files.each do |rf|
      mount_point = rf.split('/')[-3]
      @vault.post "v1/#{mount_point}/config/urls", File.read(rf)
    end
  end
end
