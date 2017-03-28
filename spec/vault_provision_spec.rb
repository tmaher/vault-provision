require 'spec_helper'

describe Vault::Provision do
  it "has a cubbyhole" do
    expect(client.sys.mounts[:cubbyhole].description).to \
      include 'per-token private secret storage'
  end

  it "has an ldap auth" do
    expect(client.sys.auths[:ldap].type).to be == 'ldap'
  end

  it "has a token auth" do
    expect(client.sys.auths[:token].type).to be == 'token'
  end

  it "has an ldap config" do
    config_data = client.get('v1/auth/ldap/config')[:data]
    expect(config_data[:url]).to be == 'ldaps://ldap.example.com'
  end

  it "has a pki-root mount" do
    expect(client.sys.mounts.keys).to include :'pki-root'
  end

  it "has a CA" do
    expect(client.get('v1/pki-root/ca/pem')).to be
  end

  it "has pki-root config urls" do
    expect(client.get('v1/pki-root/config/urls')[:data][:crl_distribution_points].to_s).to include 'https://cdn.example.com'
  end

  it "has pki-intermediate config urls" do
    expect(client.get('v1/pki-intermediate/config/urls')[:data][:issuing_certificates].to_s).to include 'https://cdn.example.com'
  end
end
