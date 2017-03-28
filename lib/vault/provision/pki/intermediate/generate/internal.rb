# create the CA
class Vault::Provision::Pki::Intermediate::Generate::Internal < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def provision!
    puts "** (TODO) checking pki intermediate generation"
    #return if generated? or regenerate?
  end
end
