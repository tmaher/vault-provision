# config crl & distribution points for CAs
class Vault::Provision::Pki::Config::Urls < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def provision!
    paths = @vault.sys.mounts.select { |_,a| a.type == 'pki' } .keys

    paths.each do |path|
      r_crl_file  = "#{@instance_dir}/#{path}/config/crl.json"
      r_urls_file = "#{@instance_dir}/#{path}/config/urls.json"

      r_crl  = JSON.dump(File.read(r_crl_file))
      r_urls = JSON.dump(File.read(r_urls_file))

      v_crl = @vault.get("#{path}config/crl")['data']
      same = r_crl.keys.inject(true) {|acc,elem| acc && r_crl[elem] == v_crl[elem] }
      @vault.post("#{path}config/crl", r_crl) unless same

      v_urls = @vault.get("#{path}config/urls")['data']
      same = r_urls.keys.inject(true) {|acc,elem| acc && r_urls[elem] == v_urls[elem] }
      @vault.post("#{path}config/urls", r_urls) unless same
    end
  end
end
