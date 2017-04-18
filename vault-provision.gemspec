require 'find'

Gem::Specification.new do |s|
  s.name = 'vault-provision'
  s.version = File.read("VERSION").chomp
  s.summary = 'Provisioning utility for HashiCorp\'s Vault'
  s.description = ''
  s.authors = ["Tom Maher"]
  s.email = "tmaher@pw0n.me"
  s.license = "Apache-2.0"
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/tmaher/vault-provision'

  s.add_development_dependency "rake",  '~>12'
  s.add_development_dependency "rspec", '~>3'
  s.add_dependency 'activesupport',     '~> 5.0', '>= 5.0.2'
  s.add_dependency 'rhcl',              '~>0.1.0'
  s.add_dependency 'vault',             '~>0.9.0'
end
