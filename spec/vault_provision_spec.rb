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

  it "has an approle mount" do
    expect(client.sys.auths[:approle].type).to be == 'approle'
  end

  it "has approle role for frontends" do
    resp = client.get('v1/auth/approle/role/frontends')
    expect(resp[:data]).to be
    expect(resp[:data][:secret_id_num_uses]).to be == 255
  end

  it "has an approle mount named bob" do
    expect(client.sys.auths[:bob_the_dancing_approle_mount].type).to be == 'approle'
  end

  it "bob has dreams too ya know" do
    resp = client.get('v1/auth/bob_the_dancing_approle_mount/role/dream')
    expect(resp[:data]).to be
    expect(resp[:data][:bound_cidr_list]).to be == '10.0.1.0/24'
  end

  it "in death, a member of project mayhem has a name (or at least a role-id)" do
    resp = client.get('v1/auth/bob_the_dancing_approle_mount/role/death/role-id')
    expect(resp[:data]).to be
    expect(resp[:data][:role_id]).to be == 'robert_paulson'
  end

  it "can provision generic k/v pairs" do
    good = client.get('v1/secret/foo/good')
    expect(good[:data]).to be
    expect(good[:data][:whiskers]).to be == 'on kittens'

    bad = client.get('v1/secret/bar/bad')
    expect(bad[:data][:'😡']).to be \
      == 'How I feel when people put secrets in source code.'
    expect(bad[:data][:'😀']).to be \
      == 'How I feel when people put non-secret config data in k/v stores with decent access control policies'

    yummy = client.get('v1/secret/baz/yummy')

    expect(yummy[:data]).to be
    expect(yummy[:data][:bear]).to be == '🐻  rawr!'
  end

  it "has AWS roles" do
    resp = client.get 'v1/aws/roles/iam-full-access'
    expect(resp[:data]).to be
    expect(resp[:data][:arn]).to be == 'arn:aws:iam::aws:policy/IAMFullAccess'
  end

  it "does not have nonexistant AWS roles" do
    expect {
      client.get('v1/aws/roles/your-mom')
    }.to raise_error(Vault::HTTPClientError)
  end

  it "can create valid IAM credentials with AWS managed policies" do
    unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      skip "To test - plz set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
    end

    VCR.use_cassette('aws-secret-iam-full', tag: :aws_secret) do
      resp = client.get 'v1/aws/creds/iam-full-access'
      expect(resp[:data]).to be

      access_key = resp[:data][:access_key]
      secret_key = resp[:data][:secret_key]

      expect(access_key).to match(%r{\AAKIA})
      expect(secret_key).to be

      last_used = iam_client.get_access_key_last_used access_key_id: access_key
      expect(last_used).to be
      expect(last_used.user_name).to be
    end
  end
  it "can create valid IAM credentials with custom policies" do
    unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      skip "To test - plz set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
    end

    VCR.use_cassette('aws-secret-custom', tag: :aws_secret) do
      resp = client.get 'v1/aws/creds/s3-bucket-custom'
      expect(resp[:data]).to be

      access_key = resp[:data][:access_key]
      secret_key = resp[:data][:secret_key]
      expect(access_key).to match(%r{\AAKIA})
      expect(secret_key).to be
      last_used = iam_client.get_access_key_last_used access_key_id: access_key
      expect(last_used).to be
      expect(last_used.user_name).to be
    end
  end

  it "can create audit backends" do
    resp = client.sys.audits
    expect(resp[:my_file]).to be
    expect(resp[:my_file].options[:file_path]).to be == AUDIT_LOG_PATH
    expect(resp[:my_file].description).to be == 'my file-based audit backend'
    expect(File.exist?(AUDIT_LOG_PATH)).to be true

    expect(resp[:my_syslog]).to be
    expect(resp[:my_syslog].options[:tag]).to be == AUDIT_LOG_TAG
    expect(resp[:my_syslog].options[:facility]).to be == "LPR"

    # File.unlink(AUDIT_LOG_PATH)
    Vault::Provision.new(EXAMPLE_AUDIT_DIR).provision!
    resp = client.sys.audits
    expect(resp[:my_file].options[:file_path]).to be == ALT_AUDIT_LOG_PATH
    expect(File.exist?(ALT_AUDIT_LOG_PATH)).to be true
  end
end
