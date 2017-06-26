require 'rhcl'

# prototype for the individual hierarchy paths
class Vault::Provision::Prototype
  class InvalidProvisioningFileError < RuntimeError; end

  def initialize boss
    @vault = boss.vault
    @instance_dir = boss.instance_dir
    @intermediate_issuer = boss.intermediate_issuer
    @pki_allow_destructive = boss.pki_allow_destructive
  end

  def repo_prefix
    ActiveSupport::Inflector.underscore(self.class.to_s)
                            .split('/')[2..-1].join('/')
  end

  def repo_path
    "#{@instance_dir}/#{repo_prefix}"
  end

  def repo_files
    Find.find(repo_path).select { |rf| rf.end_with?('.json') }
  end

  def mounts_by_type type
    mounts = @vault.sys.mounts
    mounts.keys.select { |mp| mounts[mp].type == type }
  end

  def repo_files_by_mount_type type
    files = []
    mounts_by_type(type).each do |mp|
      next unless Dir.exist? "#{@instance_dir}/#{mp}"
      Find.find("#{@instance_dir}/#{mp}").each do |rf|
        next unless rf.end_with? '.json'
        files << rf
      end
    end
    files
  end


  def provision!
    puts "#{self.class} says: Go climb a tree!"
  end

  def validate_file! path
    file_string = File.read(path)
    begin
      case File.extname(path)
      when '.json'
        JSON.parse file_string
      when '.hcl'
        Rhcl.parse file_string
      else
        raise InvalidProvisioningFileError.new("unknown filetype #{File.extname(path)}")
      end
      true
    rescue Racc::ParseError, JSON::ParserError, InvalidProvisioningFileError => e
      raise InvalidProvisioningFileError.new("Unable to parse file #{path}:\n🐱🐱🐱\n#{file_string}\n🐱🐱🐱\n#{e.class} #{e.message}")
    end
  end
end
