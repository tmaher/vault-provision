# AWS Secret backend, or, IAM credentials as a service
# https://www.vaultproject.io/docs/secrets/aws/index.html
class Vault::Provision::Aws::SecretBackend < Vault::Provision::Prototype
  AWS_REGION_DEFAULT = 'us-east-1'.freeze

  class Vault::Provision::Aws::SecretBackend::NoCredsError < RuntimeError
  end

  attr_accessor :access_key, :secret_key, :region

  def provision!
    provision_config_and_creds!
    provision_roles!
  end

  def provision_config_and_creds!
    return unless @aws_update_creds
    mounts_by_type('aws').each do |mp|
      mp_prefix = mp.to_s == 'aws' ? '' : "#{mp}_"

      @access_key = ENV["#{mp_prefix}AWS_ACCESS_KEY_ID"]
      @secret_key = ENV["#{mp_prefix}AWS_SECRET_ACCESS_KEY"]
      @region = ENV["#{mp_prefix}AWS_REGION"] || AWS_REGION_DEFAULT

      if @access_key.nil? || @secret_key.nil?
        raise NoCredsError,
          "set environment variables #{mp_prefix}AWS_ACCESS_KEY_ID) and #{mp_prefix}AWS_SECRET_ACCESS_KEY"
      end

      aws_config = JSON.dump(access_key: @access_key,
                             secret_key: @secret_key,
                             region:     @region)

      puts "  * AWS secret mount point #{mp} config (INCLUDING SECRET)"
      @vault.post "v1/#{mp}/config/root", aws_config

      lease_config = "#{@instance_dir}/#{mp}/config/lease.json"
      next unless FileTest.readable? lease_config

      validate_file! lease_config
      puts "  * #{mp}/config/lease"
      @vault.post "v1/#{mp}/config/lease", File.read(lease_config)
    end
  end

  def normalize_role role_file_path
    role_json = File.read(role_file_path)
    role = JSON.parse(role_json)

    if role['arn'] || role['policy']
      role_json
    elsif role['Version'] && role['Statement']
      JSON.dump(policy: role_json)
    end
  end

  def provision_roles!
    mounts_by_type('aws').each do |mp|
      next unless Dir.exist? "#{@instance_dir}/#{mp}"
      puts "  * AWS secret mount point #{mp} roles"

      Find.find("#{@instance_dir}/#{mp}/roles").each do |rf|
        next unless rf.end_with? '.json'
        validate_file! rf
        role_definition = normalize_role rf
        next if role_definition.nil?
        role_path = rf.sub(%r{\A#{@instance_dir}\/}, '').sub(/.json\z/, '')

        puts "    * #{role_path}"
        @vault.post "v1/#{role_path}", role_definition
      end
    end
  end
end
