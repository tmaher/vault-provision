require 'spec_helper'

describe Vault::Provision do
  it "has a cubbyhole" do
    expect(client.sys.mounts[:cubbyhole].description).to \
      include 'per-token private secret storage'
  end

  it "has an ldap auth" do
    expect(client.sys.auths[:ldap].type).to be == 'ldap'
  end

  it "has an ldap admin group" do
    resp = client.get('v1/auth/ldap/groups/admin')
    expect(resp[:data]).to be
    expect(resp[:data][:policies].split(',')).to include 'security_admin'
  end

  it "has an ldap operators group" do
    resp = client.get('v1/auth/ldap/groups/operators')
    expect(resp[:data]).to be
    expect(resp[:data][:policies]).to include 'master_of_secrets'
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
    expect(client.get('v1/pki-root/ca/pem')).to include "BEGIN CERTIFICATE"
  end

  it "has pki-root config urls" do
    expect(client.get('v1/pki-root/config/urls')[:data][:crl_distribution_points].to_s).to include 'https://cdn.example.com'
  end

  it "has pki-intermediate config urls" do
    expect(client.get('v1/pki-intermediate/config/urls')[:data][:issuing_certificates].to_s).to include 'https://cdn.example.com'
  end

  it "has pki-intermediate ca" do
    expect(client.get('v1/pki-intermediate/ca/pem')).to include "BEGIN CERTIFICATE"
  end

  it "has a dvcert role for intermediate" do
    expect(client.get('v1/pki-intermediate/roles/dvcert')[:data][:allowed_domains]).to include "vault.example.com"
    expect(client.get('v1/pki-intermediate/roles/dvcert')[:data][:allow_any_name]).to be_falsey
  end

  it "has an unlimited role for root" do
    expect(client.get('v1/pki-root/roles/unlimited')[:data][:allow_any_name]).to be_truthy
  end

  it "has a master_of_secrets policy" do
    expect(client.sys.policy('master_of_secrets').rules).to include '"sys/auth/*"'
    expect(client.sys.policy('master_of_secrets').rules).to include '"secret/*"'
  end

  it "has a secret squirrel" do
    expect(client.sys.mounts[:squirrel].type).to be == 'generic'
  end

  it "has an approle" do
    expect(client.sys.auths[:approle].type).to be == 'approle'
  end
end
