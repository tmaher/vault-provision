# Generic secret (k/v pairs) backend provisioning
#
# WARNING: Use of this module will inevitably lead you down
# the path of commiting secrets into repositories. Sometimes,
# that's ok! For example, consider using Vault's generic backend
# to store non-secret data, like a set of public certificates
# (but not their private keys).
# https://www.vaultproject.io/api/secret/generic/index.html
class Vault::Provision::Secret < Vault::Provision::Prototype
  def provision!
    repo_files.each do |rf|
      validate_file! rf

      puts "rf is #{rf}"
      puts "  * #{File.basename(rf, '.json')}"
    end
  end
end
