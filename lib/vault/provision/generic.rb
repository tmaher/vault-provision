# Generic secret (k/v pairs) backend provisioning
class Vault::Provision::Generic < Vault::Provision::Prototype
  # the generic secret API doesn't have anything to configure!
  # https://www.vaultproject.io/api/secret/generic/index.html
  def provision!
    true
  end
end
