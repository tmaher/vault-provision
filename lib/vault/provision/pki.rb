# PKI/CA backend provisioning
module Vault::Provision::Pki
  def self.generated? path
    @vault.get "#{path}/ca/pem"
    true
  rescue Vault::HTTPClientError
    false
  end

  def self.ca_type path
    path.match(/pki-intermediate/) && true
  end

  # placeholder
  module Root; end

  # placeholder
  module Intermediate; end
end

# config crl & distribution points for CAs
class Vault::Provision::Pki::Config < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def provision!
    paths = @vault.sys.mounts.select { |_,a| a.type == :pki } .keys

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

# create the CA
class Vault::Provision::Pki::Root::Generate < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def provision!
    return if generated? or regenerate?
    "oop"
  end
end
