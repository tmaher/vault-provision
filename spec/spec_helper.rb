$: << File.dirname(__FILE__) + '/../lib'

require 'vault_provision'

DEV_VAULT_TOKEN                = 'kittens'.freeze
DEV_VAULT_ADDR                 = 'http://127.0.0.1:8200'.freeze

ENV['VAULT_DEV_ROOT_TOKEN_ID'] = DEV_VAULT_TOKEN
ENV['VAULT_TOKEN']             = DEV_VAULT_TOKEN
ENV['VAULT_ADDR']              = DEV_VAULT_ADDR

Vault.configure do |config|
  config.address = DEV_VAULT_ADDR
  config.token = DEV_VAULT_TOKEN
end

def vault_server
  @test_server ||= IO.popen('vault server -dev')
end

def vault_client
  @vault_client ||= Vault::Client.new
end

RSpec.configure do |config|
  config.tty = true
  config.raise_errors_for_deprecations!
end

vault_server
vault_client
