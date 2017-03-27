GEM_DIR=File.expand_path(File.dirname(__FILE__) + '/../').freeze
$: << "#{GEM_DIR}/lib"

require 'vault_provision'
require 'open3'

DEV_VAULT_TOKEN                = 'kittens'.freeze
DEV_VAULT_ADDR                 = 'http://127.0.0.1:8200'.freeze
EXAMPLE_DIR                    = "#{GEM_DIR}/examples/basic".freeze

ENV['VAULT_DEV_ROOT_TOKEN_ID'] = DEV_VAULT_TOKEN
ENV['VAULT_TOKEN']             = DEV_VAULT_TOKEN
ENV['VAULT_ADDR']              = DEV_VAULT_ADDR

Vault.configure do |config|
  config.address = DEV_VAULT_ADDR
  config.token = DEV_VAULT_TOKEN
end

def vault_server
  stdin, stdout, stderr, server = Open3.popen3('vault server -dev')
  cleanup = lambda do |_|
    stdin.close
    stdout.close
    stderr.close
    Process.kill :INT, server.pid
  end
  [:INT, :EXIT].each { |sig| trap(sig, cleanup) }
end

def client
  @client ||= Vault::Client.new
end

RSpec.configure do |config|
  config.tty = true
  config.raise_errors_for_deprecations!
end

vault_server

#Vault::Provision.new
